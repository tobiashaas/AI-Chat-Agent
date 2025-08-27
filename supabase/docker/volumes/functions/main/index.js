// Simple test function
export const handler = async (req) => {
  return new Response(
    JSON.stringify({
      message: "Hello from Supabase Edge Functions!",
      timestamp: new Date().toISOString()
    }),
    {
      headers: { "Content-Type": "application/json" }
    }
  );
};
