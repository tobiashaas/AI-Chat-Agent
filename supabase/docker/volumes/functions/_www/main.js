// AI Chat Agent Stack - Edge Function Template

export const handler = async (event, context) => {
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization"
    },
    body: JSON.stringify({
      message: "Hello from Supabase Edge Functions!",
      status: "online",
      path: event.path || "/",
      method: event.httpMethod || "GET",
      timestamp: new Date().toISOString()
    })
  };
};
