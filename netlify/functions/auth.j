// netlify/functions/auth.js
export async function handler(event) {
  const site = process.env.URL || "";
  const clientId = process.env.GITHUB_CLIENT_ID;

  // Step 1: send the user to GitHub to authorize
  if (event.httpMethod === "GET" && !event.queryStringParameters.code) {
    const redirectUri = encodeURIComponent(site + "/admin/auth");
    const url =
      `https://github.com/login/oauth/authorize?client_id=${clientId}` +
      `&scope=repo,user&redirect_uri=${redirectUri}`;
    return { statusCode: 302, headers: { Location: url } };
  }

  // Step 2: exchange code for token using Netlify’s OAuth proxy
  const code = event.queryStringParameters.code;
  const res = await fetch("https://api.netlify.com/functions/oauth/token", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ provider: "github", code })
  });
  const data = await res.json();
  if (!res.ok || !data.access_token) {
    return { statusCode: 400, body: JSON.stringify(data) };
  }
  return {
    statusCode: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ token: data.access_token })
  };
}
