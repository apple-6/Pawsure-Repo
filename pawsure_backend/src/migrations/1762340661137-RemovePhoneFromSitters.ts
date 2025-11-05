import { MigrationInterface, QueryRunner } from "typeorm";

export class RemovePhoneFromSitters1762340661137 implements MigrationInterface {
    name = 'RemovePhoneFromSitters1762340661137'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "sitters" DROP COLUMN "phoneNumber"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "sitters" ADD "phoneNumber" character varying`);
    }

}
