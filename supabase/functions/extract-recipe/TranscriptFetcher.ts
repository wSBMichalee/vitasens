import { ExternalAPIError, ValidationError } from '../_shared/errorHandler.ts';
import { SupportedPlatform } from './UrlValidator.ts';

export interface TranscriptResult {
  text: string;
  source: 'captions' | 'description' | 'title' | 'oembed';
  platform: string;
  videoId: string;
}

interface YouTubeVideoItem {
  snippet: {
    title: string;
    description: string;
    tags?: string[];
    channelTitle: string;
  };
}

interface YouTubeApiResponse {
  items: YouTubeVideoItem[];
}

interface TikTokOEmbedResponse {
  title: string;
  author_name: string;
}

interface InstagramOEmbedResponse {
  title?: string;
  author_name?: string;
}

export class TranscriptFetcher {
  private readonly youtubeApiKey: string | undefined;

  constructor() {
    this.youtubeApiKey = Deno.env.get('YOUTUBE_API_KEY');
  }

  async fetchFromYouTube(videoId: string): Promise<TranscriptResult> {
    try {
      console.log('Fetching YouTube data for:', videoId);

      if (!this.youtubeApiKey) {
        throw new ExternalAPIError('Brak klucza YouTube API.');
      }

      const params = new URLSearchParams({
        id: videoId,
        part: 'snippet,contentDetails',
        key: this.youtubeApiKey,
      });

      const response = await this.safeFetch(
        `https://www.googleapis.com/youtube/v3/videos?${params}`,
      );

      const data: YouTubeApiResponse = await response.json();
      const item = data.items?.[0];

      if (!item) {
        throw new ExternalAPIError('Film YouTube nie został znaleziony.');
      }

      const { title, description, tags, channelTitle } = item.snippet;
      const parts = [title, description, channelTitle, ...(tags ?? [])].filter(Boolean);
      const text = parts.join('\n');

      return { text, source: 'description', platform: 'youtube', videoId };
    } catch (err) {
      if (err instanceof ExternalAPIError || err instanceof ValidationError) throw err;
      throw new ExternalAPIError('Błąd podczas pobierania danych z YouTube.');
    }
  }

  async fetchFromTikTok(videoUrl: string): Promise<TranscriptResult> {
    try {
      console.log('Fetching TikTok data for:', videoUrl);

      const params = new URLSearchParams({ url: videoUrl });
      const response = await this.safeFetch(
        `https://www.tiktok.com/oembed?${params}`,
      );

      const data: TikTokOEmbedResponse = await response.json();
      const title = data.title ?? '';
      const authorName = data.author_name ?? '';
      const text = `${title} by ${authorName}`.trim();

      return { text, source: 'oembed', platform: 'tiktok', videoId: videoUrl };
    } catch (err) {
      if (err instanceof ExternalAPIError || err instanceof ValidationError) throw err;
      throw new ExternalAPIError('Błąd podczas pobierania danych z TikTok.');
    }
  }

  async fetchFromInstagram(videoUrl: string): Promise<TranscriptResult> {
    try {
      console.log('Fetching Instagram data for:', videoUrl);

      try {
        const params = new URLSearchParams({
          url: videoUrl,
          access_token: 'public_token',
        });

        const response = await this.safeFetch(
          `https://graph.facebook.com/v18.0/instagram_oembed?${params}`,
        );

        const data: InstagramOEmbedResponse = await response.json();
        const title = data.title ?? data.author_name ?? '';

        return { text: title, source: 'oembed', platform: 'instagram', videoId: videoUrl };
      } catch {
        // Fallback: wyciągnij tekst z segmentów URL
        const parsed = new URL(videoUrl);
        const slug = parsed.pathname
          .split('/')
          .filter(Boolean)
          .join(' ')
          .replace(/-/g, ' ');

        return { text: slug, source: 'oembed', platform: 'instagram', videoId: videoUrl };
      }
    } catch (err) {
      if (err instanceof ExternalAPIError || err instanceof ValidationError) throw err;
      throw new ExternalAPIError('Błąd podczas pobierania danych z Instagram.');
    }
  }

  async fetch(
    url: string,
    platform: SupportedPlatform,
    videoId: string,
  ): Promise<TranscriptResult> {
    try {
      let result: TranscriptResult;

      switch (platform) {
        case 'youtube':
          result = await this.fetchFromYouTube(videoId);
          break;
        case 'tiktok':
          result = await this.fetchFromTikTok(url);
          break;
        case 'instagram':
          result = await this.fetchFromInstagram(url);
          break;
      }

      if (!result.text || result.text.length < 10) {
        throw new ValidationError('Nie można pobrać treści z tego filmu.');
      }

      return result;
    } catch (err) {
      if (err instanceof ExternalAPIError || err instanceof ValidationError) throw err;
      throw new ExternalAPIError('Nieoczekiwany błąd podczas pobierania transkrypcji.');
    }
  }

  private async safeFetch(url: string): Promise<Response> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10_000);

    try {
      const response = await fetch(url, { signal: controller.signal });
      if (!response.ok) {
        throw new ExternalAPIError(
          `Zewnętrzne API zwróciło błąd: ${response.status} ${response.statusText}`,
        );
      }
      return response;
    } catch (err) {
      if (err instanceof ExternalAPIError) throw err;
      throw new ExternalAPIError('Przekroczono limit czasu lub błąd sieci.');
    } finally {
      clearTimeout(timeoutId);
    }
  }
}
