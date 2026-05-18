import { ValidationError } from '../_shared/errorHandler.ts';

export type SupportedPlatform = 'youtube' | 'tiktok' | 'instagram';

export class UrlValidator {
  private static readonly YOUTUBE_PATTERNS = [
    /^https?:\/\/(?:www\.)?youtube\.com\/watch\?.*v=([a-zA-Z0-9_-]{11})/,
    /^https?:\/\/youtu\.be\/([a-zA-Z0-9_-]{11})/,
    /^https?:\/\/(?:www\.)?youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})/,
  ];

  private static readonly TIKTOK_PATTERN =
    /^https?:\/\/(?:www\.|vm\.)?tiktok\.com\//;

  private static readonly INSTAGRAM_PATTERN =
    /^https?:\/\/(?:www\.)?instagram\.com\/(?:reel|p)\//;

  validate(url: string): SupportedPlatform {
    try {
      new URL(url);
    } catch {
      throw new ValidationError('Podany URL jest nieprawidłowy.');
    }

    if (UrlValidator.YOUTUBE_PATTERNS.some((re) => re.test(url))) {
      return 'youtube';
    }
    if (UrlValidator.TIKTOK_PATTERN.test(url)) {
      return 'tiktok';
    }
    if (UrlValidator.INSTAGRAM_PATTERN.test(url)) {
      return 'instagram';
    }

    throw new ValidationError(
      'Nieobsługiwana platforma. Podaj link z YouTube, TikTok lub Instagram.',
    );
  }

  extractVideoId(url: string, platform: SupportedPlatform): string {
    try {
      if (platform === 'youtube') {
        for (const pattern of UrlValidator.YOUTUBE_PATTERNS) {
          const match = url.match(pattern);
          if (match?.[1]) return match[1];
        }
        // Fallback: parse v= query param
        const parsed = new URL(url);
        const v = parsed.searchParams.get('v');
        if (v) return v;
        throw new ValidationError('Nie można wyciągnąć ID filmu YouTube z podanego URL.');
      }

      if (platform === 'tiktok') {
        const parsed = new URL(url);
        const segments = parsed.pathname.split('/').filter(Boolean);
        const last = segments.at(-1);
        if (!last) throw new ValidationError('Nie można wyciągnąć ID filmu TikTok z podanego URL.');
        return last;
      }

      if (platform === 'instagram') {
        const parsed = new URL(url);
        const segments = parsed.pathname.split('/').filter(Boolean);
        const reelIdx = segments.findIndex((s) => s === 'reel' || s === 'p');
        const id = reelIdx !== -1 ? segments[reelIdx + 1] : undefined;
        if (!id) throw new ValidationError('Nie można wyciągnąć ID posta Instagram z podanego URL.');
        return id;
      }

      throw new ValidationError('Nieobsługiwana platforma.');
    } catch (err) {
      if (err instanceof ValidationError) throw err;
      throw new ValidationError('Błąd podczas parsowania URL.');
    }
  }
}
