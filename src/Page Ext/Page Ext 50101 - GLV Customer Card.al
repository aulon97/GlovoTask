pageextension 50101 "GLV Customer Card" extends "Customer Card"
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