export interface CoachRespondRequest {
  threadId: string;
  message: string;
  locale?: 'en' | 'ru';
}

export interface CoachRespondResponse {
  threadId: string;
  reply: string;
}

// Placeholder for Supabase Edge Function handler.
// When you wire Supabase, convert this to the Deno/Edge runtime signature.
export function coachRespond(
  req: CoachRespondRequest,
): CoachRespondResponse {
  const m = (req.message ?? '').trim();
  const reply =
    m.length === 0
      ? 'Please send a message.'
      : `Got it: "${m}". (server stub)`;
  return { threadId: req.threadId, reply };
}

