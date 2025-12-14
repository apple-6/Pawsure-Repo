import { MigrationInterface, QueryRunner } from "typeorm";

// IMPORTANT: Update the class name to match the file name you created (e.g., UpdateSitterColumns1734007020000)
export class UpdateSitterColumns1734007020000 implements MigrationInterface { 
    name = 'UpdateSitterColumns1734007020000'; 

    public async up(queryRunner: QueryRunner): Promise<void> {
        // 1. Rename the old column and convert it to a TEXT array (unavailable_days)
        // This is the core fix for the original Internal Server Error.
        await queryRunner.query(`
            ALTER TABLE "sitters" 
            RENAME COLUMN "available_dates" TO "unavailable_days";
        `);
        
        // 2. Convert the content from comma-separated TEXT (e.g., 'Mon,Tue') to a native TEXT[] array
        await queryRunner.query(`
            ALTER TABLE "sitters"
            ALTER COLUMN "unavailable_days" TYPE TEXT[]
            USING string_to_array("unavailable_days"::TEXT, ',');
        `);

        // 3. Add the new column for specific unavailable calendar dates (DATE[])
        await queryRunner.query(`
            ALTER TABLE "sitters" 
            ADD COLUMN "unavailable_dates" date[] NOT NULL DEFAULT ARRAY[]::DATE[];
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Revert step 3: Drop the new dates column
        await queryRunner.query(`
            ALTER TABLE "sitters" 
            DROP COLUMN "unavailable_dates";
        `);

        // Revert step 2: Convert the array back to comma-separated text
        await queryRunner.query(`
            ALTER TABLE "sitters"
            ALTER COLUMN "unavailable_days" TYPE text
            USING array_to_string("unavailable_days", ',');
        `);
        
        // Revert step 1: Rename the column back
        await queryRunner.query(`
            ALTER TABLE "sitters" 
            RENAME COLUMN "unavailable_days" TO "available_dates";
        `);
    }
}