import { MigrationInterface, QueryRunner } from "typeorm";

export class AddVacancyToPosts1767002593360 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Wrap your SQL in backticks inside the query method
        await queryRunner.query(`
            ALTER TABLE "posts" 
            ADD COLUMN "is_vacancy" BOOLEAN NOT NULL DEFAULT false,
            ADD COLUMN "start_date" TIMESTAMP,
            ADD COLUMN "end_date" TIMESTAMP,
            ADD COLUMN "pet_id" VARCHAR;
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // This allows you to undo the migration if something goes wrong
        await queryRunner.query(`
            ALTER TABLE "posts" 
            DROP COLUMN "is_vacancy",
            DROP COLUMN "start_date",
            DROP COLUMN "end_date",
            DROP COLUMN "pet_id";
        `);
    }

}