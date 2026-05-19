import { ExternalAPIError, NotFoundError } from '../_shared/errorHandler.ts';

export interface BarcodeProduct {
  barcode: string;
  name: string;
  brand: string;
  servingSizeG: number;
  per100g: {
    proteinG: number;
    carbsG: number;
    fatG: number;
    calories: number;
  };
  imageUrl: string | null;
}

interface OFFNutriments {
  proteins_100g?: number;
  carbohydrates_100g?: number;
  fat_100g?: number;
  'energy-kcal_100g'?: number;
  energy_100g?: number;
}

interface OFFProduct {
  product_name?: string;
  brands?: string;
  serving_size?: string;
  nutriments?: OFFNutriments;
  image_url?: string;
}

interface OFFResponse {
  status: number;
  product?: OFFProduct;
}

export class BarcodeNutritionFetcher {
  private readonly baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  async fetchByBarcode(barcode: string): Promise<BarcodeProduct> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10_000);

    try {
      const response = await fetch(
        `${this.baseUrl}/${encodeURIComponent(barcode)}?fields=product_name,brands,serving_size,nutriments,image_url`,
        {
          signal: controller.signal,
          headers: { 'User-Agent': 'VitaSens/1.0 (contact@vitasens.app)' },
        },
      );

      if (!response.ok) {
        throw new ExternalAPIError(`Open Food Facts błąd: ${response.status}`);
      }

      const data: OFFResponse = await response.json();

      if (data.status === 0 || !data.product) {
        throw new NotFoundError(`Nie znaleziono produktu dla kodu: ${barcode}`);
      }

      return this.mapProduct(barcode, data.product);
    } catch (err) {
      if (err instanceof ExternalAPIError || err instanceof NotFoundError) throw err;
      throw new ExternalAPIError('Przekroczono limit czasu lub błąd połączenia z Open Food Facts.');
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private mapProduct(barcode: string, p: OFFProduct): BarcodeProduct {
    const n = p.nutriments ?? {};
    const kcalPer100 = n['energy-kcal_100g'] ?? (n.energy_100g ? n.energy_100g / 4.184 : 0);

    return {
      barcode,
      name: p.product_name?.trim() || 'Nieznany produkt',
      brand: p.brands?.split(',')[0]?.trim() || '',
      servingSizeG: this.parseServingSize(p.serving_size),
      per100g: {
        proteinG: Math.round((n.proteins_100g ?? 0) * 10) / 10,
        carbsG: Math.round((n.carbohydrates_100g ?? 0) * 10) / 10,
        fatG: Math.round((n.fat_100g ?? 0) * 10) / 10,
        calories: Math.round(kcalPer100),
      },
      imageUrl: p.image_url ?? null,
    };
  }

  private parseServingSize(raw?: string): number {
    if (!raw) return 100;
    const match = raw.match(/(\d+(?:[.,]\d+)?)/);
    return match ? parseFloat(match[1].replace(',', '.')) : 100;
  }
}
