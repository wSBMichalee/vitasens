import { corsHeaders } from './corsHeaders.ts';

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export class NotFoundError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'NotFoundError';
  }
}

export class ExternalAPIError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ExternalAPIError';
  }
}

export type SubscriptionErrorCode = 'SUBSCRIPTION_EXPIRED' | 'FAMILY_ADDON_REQUIRED';

export class SubscriptionError extends Error {
  public readonly errorCode: SubscriptionErrorCode;

  constructor(message: string, errorCode: SubscriptionErrorCode) {
    super(message);
    this.name = 'SubscriptionError';
    this.errorCode = errorCode;
  }
}

export function handleError(error: unknown): Response {
  console.error('[Error Handler] Wystąpił błąd:', error);

  let statusCode = 500;
  let errorMessage = 'Wystąpił nieoczekiwany błąd serwera.';
  let additionalData: Record<string, any> = {};

  if (error instanceof ValidationError) {
    statusCode = 400;
    errorMessage = error.message;
  } else if (error instanceof NotFoundError) {
    statusCode = 404;
    errorMessage = error.message;
  } else if (error instanceof SubscriptionError) {
    statusCode = 403;
    errorMessage = error.message;
    additionalData = { errorCode: error.errorCode };
  } else if (error instanceof ExternalAPIError) {
    statusCode = 502;
    errorMessage = 'Wystąpił problem podczas komunikacji z serwisem zewnętrznym.';
  } else if (error instanceof Error) {
    // Nie zwracamy stack trace do klienta, obsługujemy tylko znane, bezpieczne komunikaty
    if (error.message.includes('JSON')) {
      statusCode = 400;
      errorMessage = 'Nieprawidłowy format żądania (oczekiwano poprawnego JSON).';
    }
  }

  const responseBody = {
    success: false,
    error: errorMessage,
    ...additionalData
  };

  return new Response(JSON.stringify(responseBody), {
    status: statusCode,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
