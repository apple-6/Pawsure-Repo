import { MigrationInterface, QueryRunner } from "typeorm";

export class HandleNullUserIds1735558800000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Use the actual database column name
    await queryRunner.query(`
      UPDATE posts SET "userId" = 1 WHERE "userId" IS NULL
    `);

    // Now add the NOT NULL constraint
    await queryRunner.query(`
      ALTER TABLE posts 
      ALTER COLUMN "userId" SET NOT NULL
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE posts 
      ALTER COLUMN "userId" DROP NOT NULL
    `);
  }
}