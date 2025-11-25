export declare global {
  namespace Express {
    interface Request {
      // customProps of pino-http
      customProps: object;
    }

    interface User {
      userId: string;
      email: string;
    }
  }
}
