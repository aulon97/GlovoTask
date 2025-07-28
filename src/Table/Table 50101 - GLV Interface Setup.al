table 50101 "GLV Interface Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Interface Cust. Template"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default Interface Customer Template';
            TableRelation = "Customer Templ.";
        }
        field(3; "Automatic Vendor Creation"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Automatic Vendor Creation';
        }
        field(4; "Interface Vend. Template"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default Interface Vendor Template';
            TableRelation = "Vendor Templ.";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}