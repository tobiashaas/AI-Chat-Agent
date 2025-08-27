
// AI Chat Agent Stack - Edge Function Template
// Using default serve export from Deno
// This is compatible with Supabase Edge Runtime

export async function handler(req) {
  const url = new URL(req.url);
  const method = req.method;
  
  try {
    return new Response(
      JSON.stringify({ 
        message: "Hello from Supabase Edge Functions!", 
        status: "online",
        path: url.pathname,
        method: method,
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization"
        },
        status: 200
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { "Content-Type": "application/json" },
        status: 500
      }
    )
  }
}
