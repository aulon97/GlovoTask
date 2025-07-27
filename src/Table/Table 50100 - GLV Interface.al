table 50100 "GLV Interface"
{
    Caption = 'Interface', Comment = 'DEU="Schnittstelle"';

    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Guid"; Guid)
        {
            Caption = 'Guid';
            DataClassification = ToBeClassified;
        }
        field(2; Type; Enum "GLV Interface Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
        }
        field(3; Json; Blob)
        {
            Caption = 'Json';
            DataClassification = ToBeClassified;
        }
        field(4; "Has Json"; Boolean)
        {
            Caption = 'Has Json';
            DataClassification = ToBeClassified;
        }
        field(5; Direction; Enum "GLV Interface Direction")
        {
            Caption = 'Direction';
            DataClassification = ToBeClassified;
        }
        field(6; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = ToBeClassified;
        }
        field(7; "Error"; Text[2048])
        {
            Caption = 'Error';
            DataClassification = ToBeClassified;
        }
        field(8; "Created at"; DateTime)
        {
            Caption = 'Created at';
            DataClassification = ToBeClassified;
        }
        field(9; "Creted By"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Created By';
        }
    }

    keys
    {
        key(PK; "Guid", "Created at")
        {
            Clustered = true;
        }

    }
}