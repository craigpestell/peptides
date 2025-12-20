
import 'dotenv/config';
import { app } from './app.js';
import { migrateToLatest } from '@storecraft/database-mysql/migrate.js';

await migrateToLatest(app.__show_me_everything.db, true);

try {
  await app.__show_me_everything.vector_store?.createVectorIndex();
  console.log('Vector store index created successfully');
} catch (error) {
  console.log('Vector store index creation skipped - MongoDB might not be ready:', error.message);
}
