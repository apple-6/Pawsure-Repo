import { MigrationInterface, QueryRunner } from "typeorm";

export class  $npmConfigName1763437588399 implements MigrationInterface {
    name = ' $npmConfigName1763437588399'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "sitters" DROP COLUMN "phoneNumber"`);
        await queryRunner.query(`ALTER TABLE "sitters" ADD "deleted_at" TIMESTAMP`);
        await queryRunner.query(`ALTER TABLE "users" ADD "phone_number" character varying`);
        await queryRunner.query(`ALTER TABLE "users" ADD CONSTRAINT "UQ_17d1817f241f10a3dbafb169fd2" UNIQUE ("phone_number")`);
        await queryRunner.query(`ALTER TABLE "sitters" DROP COLUMN "available_dates"`);
        await queryRunner.query(`ALTER TABLE "sitters" ADD "available_dates" text`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "hasGarden" SET NOT NULL`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "hasGarden" SET DEFAULT false`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "hasOtherPets" SET NOT NULL`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "hasOtherPets" SET DEFAULT false`);
        await queryRunner.query(`ALTER TYPE "public"."sitters_status_enum" RENAME TO "sitters_status_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."sitters_status_enum" AS ENUM('pending', 'approved', 'rejected')`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "status" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "status" TYPE "public"."sitters_status_enum" USING "status"::"text"::"public"."sitters_status_enum"`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "status" SET DEFAULT 'pending'`);
        await queryRunner.query(`DROP TYPE "public"."sitters_status_enum_old"`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "status" DROP NOT NULL`);
        await queryRunner.query(`ALTER TABLE "users" ALTER COLUMN "email" DROP NOT NULL`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" ALTER COLUMN "email" SET NOT NULL`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "status" SET NOT NULL`);
        await queryRunner.query(`CREATE TYPE "public"."sitters_status_enum_old" AS ENUM('pending', 'verified', 'rejected')`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "status" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "status" TYPE "public"."sitters_status_enum_old" USING "status"::"text"::"public"."sitters_status_enum_old"`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "status" SET DEFAULT 'pending'`);
        await queryRunner.query(`DROP TYPE "public"."sitters_status_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."sitters_status_enum_old" RENAME TO "sitters_status_enum"`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "hasOtherPets" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "hasOtherPets" DROP NOT NULL`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "hasGarden" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "sitters" ALTER COLUMN "hasGarden" DROP NOT NULL`);
        await queryRunner.query(`ALTER TABLE "sitters" DROP COLUMN "available_dates"`);
        await queryRunner.query(`ALTER TABLE "sitters" ADD "available_dates" date array`);
        await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "UQ_17d1817f241f10a3dbafb169fd2"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "phone_number"`);
        await queryRunner.query(`ALTER TABLE "sitters" DROP COLUMN "deleted_at"`);
        await queryRunner.query(`ALTER TABLE "sitters" ADD "phoneNumber" character varying`);
    }

}
