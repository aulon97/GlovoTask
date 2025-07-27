pageextension 50100 "GLV Customer List" extends "Customer List"
{
    layout
    {
        addafter("No.")
        {
            field("External Id."; Rec."External Id.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the External Id. field.', Comment = '%';
            }
        }
    }
}