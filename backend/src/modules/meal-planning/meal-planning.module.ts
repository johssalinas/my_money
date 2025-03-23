import { Module } from '@nestjs/common';
import { MealPlanningService } from './meal-planning.service';
import { MealPlanningController } from './meal-planning.controller';

@Module({
  controllers: [MealPlanningController],
  providers: [MealPlanningService],
  exports: [MealPlanningService],
})
export class MealPlanningModule {} 