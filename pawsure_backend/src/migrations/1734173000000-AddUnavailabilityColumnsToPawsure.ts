import { MigrationInterface, QueryRunner } from "typeorm";

export class AddUnavailabilityColumnsToPawsure1734173000000 implements MigrationInterface { 
    // You should ensure this name matches the name in your file.

    public async up(queryRunner: QueryRunner): Promise<void> {
        // --- 1. Add unavailable_dates (DATE array) ---
        // Using the correct, simplified PostgreSQL syntax: DATE[]
        await queryRunner.query(`
            ALTER TABLE "sitters" 
            ADD COLUMN "unavailable_dates" date[] NOT NULL DEFAULT ARRAY[]::date[];
        `);
        
        // --- 2. Add unavailable_days (TEXT array) ---
        // Using the correct, simplified PostgreSQL syntax: TEXT[]
        await queryRunner.query(`
            ALTER TABLE "sitters" 
            ADD COLUMN "unavailable_days" text[] NOT NULL DEFAULT ARRAY[]::text[];
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Rollback: drop the columns
        await queryRunner.query(`
            ALTER TABLE "sitters" 
            DROP COLUMN "unavailable_days";
        `);
        
        await queryRunner.query(`
            ALTER TABLE "sitters" 
            DROP COLUMN "unavailable_dates";
        `);
    }
}