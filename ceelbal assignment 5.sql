--Sruti Prakash Behera

-- Ensure the SubjectAllotments table exists
IF OBJECT_ID('SubjectAllotments', 'U') IS NOT NULL
    DROP TABLE SubjectAllotments;

CREATE TABLE SubjectAllotments (
    StudentID varchar(50),
    SubjectID varchar(50),
    Is_Valid bit
);

-- Ensure the SubjectRequest table exists
IF OBJECT_ID('SubjectRequest', 'U') IS NOT NULL
    DROP TABLE SubjectRequest;

CREATE TABLE SubjectRequest (
    StudentID varchar(50),
    SubjectID varchar(50)
);

-- Insert sample data into SubjectAllotments table
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
VALUES 
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

-- Insert sample data into SubjectRequest table
INSERT INTO SubjectRequest (StudentID, SubjectID)
VALUES 
('159103036', 'PO1496');

-- Drop the existing procedure if it exists
IF OBJECT_ID('UpdateSubjectAllotments', 'P') IS NOT NULL
    DROP PROCEDURE UpdateSubjectAllotments;
GO

-- Create the new procedure
CREATE PROCEDURE UpdateSubjectAllotments
AS
BEGIN
    -- Temporary table to store results for display
    CREATE TABLE #Result (
        StudentID varchar(50),
        SubjectID varchar(50),
        Is_Valid bit
    );

    -- Declare necessary variables
    DECLARE @StudentID varchar(50);
    DECLARE @SubjectID varchar(50);
    DECLARE @CurrentSubjectID varchar(50);

    -- Declare a cursor to iterate through the SubjectRequest table
    DECLARE cur CURSOR FOR
    SELECT StudentID, SubjectID
    FROM SubjectRequest;

    OPEN cur;

    FETCH NEXT FROM cur INTO @StudentID, @SubjectID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student ID exists in the SubjectAllotments table
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID)
        BEGIN
            -- Get the current valid subject for the student
            SELECT @CurrentSubjectID = SubjectID
            FROM SubjectAllotments
            WHERE StudentID = @StudentID AND Is_Valid = 1;

            -- Check if the requested subject is different from the current subject
            IF @CurrentSubjectID != @SubjectID
            BEGIN
                -- Update the current valid subject to invalid
                UPDATE SubjectAllotments
                SET Is_Valid = 0
                WHERE StudentID = @StudentID AND Is_Valid = 1;

                -- Insert the new requested subject as valid
                INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
                VALUES (@StudentID, @SubjectID, 1);
            END
        END
        ELSE
        BEGIN
            -- Insert the new student and subject as valid
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @SubjectID, 1);
        END
        FETCH NEXT FROM cur INTO @StudentID, @SubjectID;
    END
    CLOSE cur;
    DEALLOCATE cur;
    -- Insert final state of SubjectAllotments into the temporary table for display
    INSERT INTO #Result
    SELECT * FROM SubjectAllotments;
    -- Display the results
    SELECT * FROM #Result;
    -- Drop the temporary table
    DROP TABLE #Result;
END
GO
-- Execute the procedure
EXEC UpdateSubjectAllotments;