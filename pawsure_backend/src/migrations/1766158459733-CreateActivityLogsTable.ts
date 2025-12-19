import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateActivityLogsTable1766158459733 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE activity_logs (
        id SERIAL PRIMARY KEY,
        pet_id INTEGER NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
        activity_type VARCHAR(50) NOT NULL,
        title VARCHAR(255),
        description TEXT,
        duration_minutes INTEGER NOT NULL,
        distance_km DECIMAL(10, 2),
        calories_burned INTEGER,
        activity_date TIMESTAMP NOT NULL,
        route_data JSONB,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
      
      CREATE INDEX idx_activity_logs_pet_id ON activity_logs(pet_id);
      CREATE INDEX idx_activity_logs_date ON activity_logs(activity_date DESC);
      CREATE INDEX idx_activity_logs_type ON activity_logs(activity_type);
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE activity_logs;`);
  }
}
