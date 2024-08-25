# CloudflareDomainsEmailKit ⚠️

Send Emails From Your Cloudflare Domains Email using Swift

## ⚠️ MailChannels End of Life Notice - Cloudflare Workers
> Since launching our free email sending API for Cloudflare Workers customers, we have been proud to provide a simple yet effective solution to deliver messages from Workers code with a minimum of setup complexity. Unfortunately, we regret to announce that this free service will be coming to an end on June 30th, 2024.

Read the full announcement [here](https://support.mailchannels.com/hc/en-us/articles/26814255454093-End-of-Life-Notice-Cloudflare-Workers)

Since sending emails via mailchannels from a cloudflare worker is no longer possible, this package will not work.

# Requirements

1. A Cloudflare domain

# Usage

MailChannels Send API lets you send emails from your Cloudflare Workers apps. Learn more about MailChannels [here.](https://support.mailchannels.com/hc/en-us/articles/4565898358413-Sending-Email-from-Cloudflare-Workers-using-MailChannels-Send-API)

You do not need an account with MailChannels to start sending emails

However, you are required to have a Domain Lockdown DNS record authorizing your Worker to send emails for your domain.

For our use case do the following:

## 1. Set up Sender Policy Framework(SPF) Records

The following records are needed for SPF to work correctly.

| Location                   | Record Type | Value                                           |
| -------------------------- | ----------- | ----------------------------------------------- |
| example.com                | TXT         | v=spf1 a mx include:relay.mailchannels.net ~all |
| \_mailchannels.example.com | TXT         | v=mc1 cfid=myapp.workers.dev                    |

Replace `example.com` with your domain name.

You are likely to have configured email routing for your domain and therefore, you have an existing TXT record pointing to the root of your domain.

In this case update your record to something that looks like `v=spf1 include:_spf.mx.cloudflare.net include:relay.mailchannels.net ~all`

Replace `cfid=myapp.workers.dev` with the `cfid` of the worker that will be resposible for emails (more on this in section 2),

Your cfid is located at [dash.cloudflare.com](dash.cloudflare.com) > Workers & Pages > Overview. Beneath "Your subdomain" at the right side of the page.

## 2. Create your Worker

On the Workers & Pages Overview Page, click on Create Application.

Create and deploy a Hello World script. You can only edit the worker after deployment.

Replace the code with the following, then click on save and deploy.

```javascript
async function readRequestBody(request) {
  const { headers } = request;
  const contentType = headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    return JSON.stringify(await request.json());
  } else {
    return '{"success":false}';
  }
}

async function handleRequest(request) {
  let start = Date.now();
  let reqBody = await readRequestBody(request);
  let sendRequest = new Request("https://api.mailchannels.net/tx/v1/send", {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: reqBody,
  });
  let resp = await fetch(sendRequest);
  let respText = await resp.text();
  let end = Date.now();
  let total = end - start;
  return new Response(respText, {
    headers: {
      "X-MC-Status": `${resp.status}`,
      "X-MC-Status-Text": resp.statusText,
      "X-Response-Time": `${total}`,
    },
  });
}

addEventListener("fetch", (event) => {
  const { request } = event;

  if (request.method === "POST") {
    return event.respondWith(handleRequest(request));
  } else if (request.method === "GET") {
    return event.respondWith(new Response(`The request was a GET`));
  }
});
```

Take note of the domain of your worker you will need that for section 3

## 3. Sending emails from Swift Server

To get started, add the CloudflareDomainsEmailKit dependency:

```swift
.package(url: "https://github.com/iankoex/CloudflareDomainsEmailKit.git", from: "0.1.4")
```

And add it as a dependency of your target:

```swift
.product(name: "CloudflareDomainsEmailKit", package: "CloudflareDomainsEmailKit")
```

Create the content.

```swift
let content = EmailContent(
    personalizations: [
        EmailContent.Personalization(
            recipients: [
                MailUser(name: "User 1", email: "username@email.com")
            ]
        )
    ],
    from: MailUser(name: "Support", email: "support@example.com"),
    subject: "Your App Data",
    content: [
        EmailContent.EmailBody(type: .plainText,value: "This is the email's body")
    ]
)
```

Send the email.

``` swift 
try await EmailClient.sendMail(content: content, using: "https://app.workers.dev/")
```
