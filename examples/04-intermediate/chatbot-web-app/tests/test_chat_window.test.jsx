"""
Unit tests for React components.
"""
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import axios from 'axios';
import ChatWindow from '../src/components/ChatWindow';
import '@testing-library/jest-dom';

jest.mock('axios');

describe('ChatWindow Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders chat window header', () => {
    render(<ChatWindow />);
    expect(screen.getByText('チャットボット')).toBeInTheDocument();
    expect(screen.getByText('AI アシスタントとの会話')).toBeInTheDocument();
  });

  test('renders initial assistant message', () => {
    render(<ChatWindow />);
    expect(screen.getByText('こんにちは！何かお手伝いできることはありますか？')).toBeInTheDocument();
  });

  test('renders input field and send button', () => {
    render(<ChatWindow />);
    expect(screen.getByPlaceholderText('メッセージを入力...')).toBeInTheDocument();
    expect(screen.getByText('送信')).toBeInTheDocument();
  });

  test('send button is disabled when input is empty', () => {
    render(<ChatWindow />);
    const sendButton = screen.getByText('送信');
    expect(sendButton).toBeDisabled();
  });

  test('send button is enabled when input has text', () => {
    render(<ChatWindow />);
    const input = screen.getByPlaceholderText('メッセージを入力...');
    const sendButton = screen.getByText('送信');

    fireEvent.change(input, { target: { value: 'Hello' } });
    expect(sendButton).not.toBeDisabled();
  });

  test('message is sent when form is submitted', async () => {
    axios.post.mockResolvedValue({
      data: {
        success: true,
        message: 'AI response'
      }
    });

    render(<ChatWindow />);
    const input = screen.getByPlaceholderText('メッセージを入力...');
    const sendButton = screen.getByText('送信');

    fireEvent.change(input, { target: { value: 'Hello' } });
    fireEvent.click(sendButton);

    await waitFor(() => {
      expect(axios.post).toHaveBeenCalledWith(
        '/api/chat',
        expect.objectContaining({
          message: 'Hello'
        })
      );
    });
  });

  test('calls API with conversation history', async () => {
    axios.post.mockResolvedValue({
      data: {
        success: true,
        message: 'New response'
      }
    });

    render(<ChatWindow />);
    const input = screen.getByPlaceholderText('メッセージを入力...');

    fireEvent.change(input, { target: { value: 'Message 1' } });
    fireEvent.click(screen.getByText('送信'));

    await waitFor(() => {
      axios.post.mockClear();
    });

    fireEvent.change(input, { target: { value: 'Message 2' } });
    fireEvent.click(screen.getByText('送信'));

    await waitFor(() => {
      expect(axios.post).toHaveBeenCalledWith(
        '/api/chat',
        expect.objectContaining({
          conversation_history: expect.arrayContaining([
            expect.objectContaining({ content: 'Message 1' })
          ])
        })
      );
    });
  });

  test('displays error message on API failure', async () => {
    axios.post.mockRejectedValue({
      response: {
        data: {
          error: 'API error'
        }
      }
    });

    render(<ChatWindow />);
    const input = screen.getByPlaceholderText('メッセージを入力...');

    fireEvent.change(input, { target: { value: 'Hello' } });
    fireEvent.click(screen.getByText('送信'));

    await waitFor(() => {
      expect(screen.getByText(/エラー: API error/)).toBeInTheDocument();
    });
  });
});
