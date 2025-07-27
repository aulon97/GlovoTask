tableextension 50100 "GLV Customer" extends Customer
{
    fields
    {
        field(50100; "External Id."; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'External Id';
            Editable = false;
        }
    }
}