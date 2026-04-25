// -----------------------------
// Main Lambda Handler
// -----------------------------
exports.handler = async (event) => {
  try {
    console.log("Incoming event:", JSON.stringify(event));

    const rawBody = event.body;
    if (!rawBody) return slackResponse("No payload received.");

    const params = new URLSearchParams(rawBody);
    const rawPayload = params.get("payload");
    if (!rawPayload) return slackResponse("No payload received.");

    const payload = JSON.parse(rawPayload);
    console.log("Parsed Slack payload:", payload);

    const actionId = payload.actions?.[0]?.action_id;
    if (!actionId) return slackResponse("No action detected.");

    // -----------------------------
    // PROMOTE TO PRODUCTION
    // -----------------------------
    if (actionId === "promote_to_production") {
      await triggerGitHubDispatch("promote_to_production");
      return slackResponse("🚀 Promotion triggered!");
    }

    // -----------------------------
    // ROLLBACK PREVIEW (FIRST CLICK)
    // -----------------------------
    if (actionId === "rollback_production") {
      await triggerGitHubDispatch("rollback_preview");
      return slackResponse("⏳ Rollback preview requested...");
    }

    // -----------------------------
    // CONFIRM ROLLBACK
    // -----------------------------
    if (actionId === "rollback_confirm") {
      await triggerGitHubDispatch("rollback_confirm");
      return slackResponse("🔄 Rollback confirmed!");
    }

    // -----------------------------
    // CANCEL ROLLBACK
    // -----------------------------
    if (actionId === "rollback_cancel") {
      await triggerGitHubDispatch("rollback_cancel");
      return slackResponse("❎ Rollback cancelled.");
    }

    return slackResponse("Unknown action.");
  } catch (err) {
    console.error("Lambda error:", err);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ error: "Internal Server Error" })
    };
  }
};

// -----------------------------
// GitHub Dispatch Trigger
// -----------------------------
async function triggerGitHubDispatch(eventType) {
  const url = "https://api.github.com/repos/Franklindot04/devops-deployment-automation/dispatches";

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `token ${process.env.GITHUB_TOKEN}`,
      Accept: "application/vnd.github.v3+json"
    },
    body: JSON.stringify({
      event_type: eventType
    })
  });

  const text = await response.text();
  console.log("GitHub response:", text);
}

// -----------------------------
// Slack Response
// -----------------------------
function slackResponse(message) {
  return {
    statusCode: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text: message })
  };
}
