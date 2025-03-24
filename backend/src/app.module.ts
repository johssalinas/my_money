import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

// Importar módulos desde el directorio modules
import { ActivitiesModule } from './modules/activities/activities.module';
import { ShoppingModule } from './modules/shopping/shopping.module';
import { MealPlanningModule } from './modules/meal-planning/meal-planning.module';
import { RemindersModule } from './modules/reminders/reminders.module';
import { FinancesModule } from './modules/finances/finances.module';
import { UsersModule } from './modules/users/users.module';
import { AuthModule } from './modules/auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';

import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule,
    AuthModule,
    UsersModule,
    ActivitiesModule,
    ShoppingModule,
    MealPlanningModule,
    RemindersModule,
    FinancesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
