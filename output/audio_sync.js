// Audio Synchronization Controller for reveal.js

class AudioSyncController {
  constructor() {
    this.currentAudio = null;
    this.currentToken = 0;
    this.isAutoPlayEnabled = true;
    this.setupEventListeners();
  }

  setupEventListeners() {
    Reveal.on('slidechanged', (event) => {
      this.onSlideChange(event);
    });

    document.addEventListener('keydown', (e) => {
      if (e.key.toLowerCase() === 'p') this.toggleAudioPanel();
      if (e.key.toLowerCase() === 'a') this.toggleAutoPlay();
    });
  }

  stopCurrentAudio() {
    if (this.currentAudio) {
      this.currentAudio.onended = null;
      this.currentAudio.pause();
      this.currentAudio.currentTime = 0;
      this.currentAudio = null;
    }
  }

  async onSlideChange(event) {
    this.currentToken += 1;
    const token = this.currentToken;

    this.stopCurrentAudio();
    if (!this.isAutoPlayEnabled) return;

    const audioNodes = Array.from(event.currentSlide.querySelectorAll('.slide-audio-item'));
    if (audioNodes.length === 0) {
      this.updateAudioPanel(null, 0, 0);
      return;
    }

    for (let i = 0; i < audioNodes.length; i += 1) {
      if (token !== this.currentToken) return;

      const audio = audioNodes[i];
      this.currentAudio = audio;
      this.updateAudioPanel(audio, i + 1, audioNodes.length);

      const completed = await this.playSingleAudio(audio, token);
      if (!completed) return;
    }

    if (token === this.currentToken) {
      setTimeout(() => {
        if (token === this.currentToken) Reveal.next();
      }, 250);
    }
  }

  playSingleAudio(audio, token) {
    return new Promise((resolve) => {
      const cleanup = () => {
        audio.onended = null;
        audio.onerror = null;
      };

      audio.onended = () => {
        cleanup();
        resolve(token === this.currentToken);
      };

      audio.onerror = () => {
        cleanup();
        console.warn('Audio load/play error:', audio.currentSrc || audio.src);
        resolve(token === this.currentToken);
      };

      audio.currentTime = 0;
      const playPromise = audio.play();
      if (playPromise && typeof playPromise.then === 'function') {
        playPromise.catch((err) => {
          cleanup();
          if (err && err.name !== 'AbortError') {
            console.warn('Audio playback failed:', err);
          }
          resolve(false);
        });
      }
    });
  }

  updateAudioPanel(audio, sequence, total) {
    const panel = document.getElementById('audio-panel');
    const currentDiv = document.getElementById('current-audio');
    if (!panel || !currentDiv) return;

    panel.style.display = 'block';
    if (!audio) {
      currentDiv.innerHTML = '<p style="margin:0;">このスライドに音声はありません</p>';
      return;
    }

    const fileName = (audio.dataset.file || audio.currentSrc || '').split('/').pop();
    currentDiv.innerHTML = `
      <p style="margin:0; line-height:1.5;">
        <strong>${fileName}</strong><br/>
        <span>${sequence}/${total} トラック</span>
      </p>
    `;
  }

  toggleAudioPanel() {
    const panel = document.getElementById('audio-panel');
    if (panel) {
      panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
    }
  }

  toggleAutoPlay() {
    this.isAutoPlayEnabled = !this.isAutoPlayEnabled;
    if (!this.isAutoPlayEnabled) this.stopCurrentAudio();
    console.log(`Auto-play ${this.isAutoPlayEnabled ? 'enabled' : 'disabled'}`);
  }
}

window.addEventListener('DOMContentLoaded', () => {
  new AudioSyncController();
  console.log('✅ AudioSyncController initialized');
  console.log('Keyboard shortcuts: P=Toggle panel, A=Toggle auto-play');
});
