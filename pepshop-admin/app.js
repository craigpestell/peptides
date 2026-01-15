import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '.env.production') });

import { OpenAI } from "@storecraft/core/ai/models/chat/openai"
import { OpenAIEmbedder } from "@storecraft/core/ai/models/embedders/openai"
import { MongoVectorStore } from "@storecraft/database-mongodb/vector-store"
import { NodePlatform } from "@storecraft/core/platform/node"
import { MySQL } from "@storecraft/database-mysql"
import { NodeLocalStorage } from "@storecraft/core/storage/node"
import { Resend } from "@storecraft/mailer-providers-http/resend"
import { Stripe } from "@storecraft/payments-stripe"
import { GoogleAuth } from "@storecraft/core/auth/providers/google"
import { FacebookAuth } from "@storecraft/core/auth/providers/facebook"
import { App } from "@storecraft/core"
import { PostmanExtension } from "@storecraft/core/extensions/postman"

export const app = new App({
  general_store_name: "pepshop",
  general_store_website: "https://pepshop.ca",
  general_store_description: "PepShop is your trusted source for high-quality research peptides. We provide a comprehensive selection of peptides for research purposes, backed by detailed protocols and educational resources. Our mission is to support researchers and scientific professionals with premium peptides, accurate product information, and exceptional customer service. All peptides are intended for research use only and should not be consumed unless under the direct supervision of a qualified healthcare professional. Discover our extensive catalog and experience the PepShop commitment to quality and research excellence.",
  auth_admins_emails: ["craigpestell@gmail.com"],
  general_store_support_email:
    "craigpestell@gmail.com",
  auth_secret_access_token: process.env.SC_AUTH_SECRET_ACCESS_TOKEN,
  auth_secret_refresh_token: process.env.SC_AUTH_SECRET_REFRESH_TOKEN,
  cors: {
    origin: ["https://pepshop.ca", "https://www.pepshop.ca"],
    credentials: true
  }
})
  .withPlatform(new NodePlatform({}))
  .withDatabase(new MySQL({
    host: process.env.MYSQL_HOST,
    port: parseInt(process.env.MYSQL_PORT),
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE,
    pool_options: {
      database: process.env.MYSQL_DATABASE,
      connectionLimit: 10
    }
  }))
  .withStorage(new NodeLocalStorage("storage"))
  .withMailer(new Resend({}))
  .withPaymentGateways({
    stripe: new Stripe({
      stripe_intent_create_params: {
        currency: "CAD",
      },
    }),
  })
  .withExtensions({
    postman: new PostmanExtension(),
  })
  .withAI(new OpenAI({}))
  // .withVectorStore(
  //   new MongoVectorStore({
  //     url: process.env.MONGODB_URL,
  //     db_name: process.env.MONGODB_DATABASE,
  //     embedder: new OpenAIEmbedder({}),
  //   }),
  // )
  .withAuthProviders({
    google: new GoogleAuth({}),
    facebook: new FacebookAuth({}),
  })
  .init()

