// Audio Synchronization Controller for reveal.js

class AudioSyncController {
  constructor() {
    this.currentAudio = null;
    this.isAutoPlayEnabled = true;
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    // スライド変更時のイベント
    Reveal.on('slidechanged', (event) => {
      this.onSlideChange(event);
    });
    
    // キーボードショートカット
    document.addEventListener('keydown', (e) => {
      if (e.key === 'p') this.toggleAudioPanel();
      if (e.key === 'a') this.toggleAutoPlay();
    });
  }
  
  onSlideChange(event) {
    // 前の音声を停止
    if (this.currentAudio) {
      this.currentAudio.pause();
      this.currentAudio.currentTime = 0;
    }
    
    // 新しいスライドの音声を取得
    const audioElement = event.currentSlide.querySelector('audio');
    if (audioElement && this.isAutoPlayEnabled) {
      this.currentAudio = audioElement;
      
      // 音声終了時に次スライドへ
      audioElement.onended = () => {
        setTimeout(() => Reveal.next(), 500);
      };
      
      // 再生開始
      audioElement.play().catch(err => {
        console.warn('Audio playback failed:', err);
      });
      
      this.updateAudioPanel(audioElement);
    }
  }
  
  updateAudioPanel(audioElement) {
    const panel = document.getElementById('audio-panel');
    if (panel) {
      panel.style.display = 'block';
      const currentDiv = document.getElementById('current-audio');
      if (currentDiv) {
        const src = audioElement.querySelector('source')?.src || 'Unknown';
        const duration = audioElement.duration.toFixed(1);
        currentDiv.innerHTML = `
          <p style="position: relative; margin: 0;">
            <strong>${src.split('/').pop()}</strong><br/>
            <audio controls style="width: 100%; margin-top: 8px;">
              ${audioElement.innerHTML}
            </audio>
          </p>
        `;
      }
    }
  }
  
  toggleAudioPanel() {
    const panel = document.getElementById('audio-panel');
    if (panel) {
      panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
    }
  }
  
  toggleAutoPlay() {
    this.isAutoPlayEnabled = !this.isAutoPlayEnabled;
    console.log(`Auto-play ${this.isAutoPlayEnabled ? 'enabled' : 'disabled'}`);
  }
}

// 初期化
window.addEventListener('DOMContentLoaded', () => {
  new AudioSyncController();
  console.log('✅ AudioSyncController initialized');
  console.log('Keyboard shortcuts: P=Toggle panel, A=Toggle auto-play');
});
