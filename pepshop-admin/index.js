
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import http from "node:http";
import { app } from './app.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '.env.production') });
 
http.createServer(app.handler).listen(
  8000,
  () => { app.print_banner('http://localhost:8000') }
); 
