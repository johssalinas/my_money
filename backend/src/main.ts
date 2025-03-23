import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as compression from 'compression';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Configurar prefijo global de las APIs
  app.setGlobalPrefix('api');
  
  // Configurar CORS
  app.enableCors({
    origin: process.env.NODE_ENV === 'production' 
      ? ['https://mymoney.com', 'https://app.mymoney.com'] 
      : '*',  // Permitir cualquier origen en desarrollo
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });
  
  // Seguridad
  app.use(helmet());
  
  // Compresión
  app.use(compression());
  
  // Validación
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  
  // Swagger
  const config = new DocumentBuilder()
    .setTitle('My Money API')
    .setDescription('API para la aplicación de gestión familiar My Money')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);
  
  // Iniciar servidor
  const port = process.env.PORT || 3001;
  await app.listen(port);
  console.log(`Application running on: ${await app.getUrl()}`);
}
bootstrap();
