import { ExternalAPIError } from '../_shared/errorHandler.ts';

export interface VisionLabel {
  description: string;
  score: number;
  topicality: number;
}

export interface VisionResponse {
  labelAnnotations: VisionLabel[];
  localizedObjectAnnotations?: any[];
}

export interface DetectionResult {
  labels: VisionLabel[];
  rawResponse: VisionResponse;
}

export class VisionClient {
  private apiKey: string;
  private baseUrl: string = 'https://vision.googleapis.com/v1/images:annotate';

  constructor() {
    const key = Deno.env.get('GOOGLE_VISION_API_KEY');
    if (!key) {
      throw new ExternalAPIError('Brak klucza Google Vision API (GOOGLE_VISION_API_KEY).');
    }
    this.apiKey = key;
  }

  async detectLabels(photoBase64: string): Promise<DetectionResult> {
    console.log('Detecting labels in base64 image');
    const request = this.buildRequest({ content: photoBase64 });
    const response = await this.callApi(request);
    
    return {
      labels: response.labelAnnotations || [],
      rawResponse: response
    };
  }

  async detectFromUrl(imageUrl: string): Promise<DetectionResult> {
    console.log('Detecting labels in image from URL:', imageUrl);
    const request = this.buildRequest({ source: { imageUri: imageUrl } });
    const response = await this.callApi(request);
    
    return {
      labels: response.labelAnnotations || [],
      rawResponse: response
    };
  }

  private buildRequest(image: object): object {
    return {
      requests: [{
        image,
        features: [
          { type: 'LABEL_DETECTION', maxResults: 20 },
          { type: 'OBJECT_LOCALIZATION', maxResults: 10 }
        ]
      }]
    };
  }

  private async callApi(requestBody: object): Promise<VisionResponse> {
    const url = `${this.baseUrl}?key=${this.apiKey}`;
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15000);

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
        signal: controller.signal
      });
      clearTimeout(timeoutId);

      if (!response.ok) {
        if (response.status === 401) throw new ExternalAPIError('Nieprawidłowy klucz Google Vision.');
        if (response.status === 429) throw new ExternalAPIError('Przekroczono limit Google Vision API.');
        throw new ExternalAPIError(`Błąd Google Vision API: ${response.statusText}`);
      }

      const data = await response.json();
      const visionResult = data.responses[0];
      
      if (visionResult.error) {
        throw new ExternalAPIError(`Google Vision API error: ${visionResult.error.message}`);
      }

      return visionResult;
    } catch (error) {
      if (error instanceof ExternalAPIError) throw error;
      throw new ExternalAPIError(`Google Vision request failed: ${error.message}`);
    }
  }
}
