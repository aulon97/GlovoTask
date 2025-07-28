tableextension 50103 "GLV Vendor" extends Vendor
{
    fields
    {
        field(50100; "External Id."; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'External Id';
            Editable = false;
            OptimizeForTextSearch = true;
        }
    }
}