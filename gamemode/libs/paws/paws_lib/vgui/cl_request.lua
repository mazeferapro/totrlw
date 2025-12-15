local MODULE = PAW_MODULE('lib')
local Colors = MODULE.Config.Colors

function MODULE:DoStringRequest(sTitle, sText, sDefaultText, fEnter, fCancel, sEnterButtonText, sCancelButtonText)

	NextRP:QuerryText(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent, sText, sDefaultText, sEnterButtonText, fEnter, sCancelButtonText, fCancelCallback)

end

function MODULE:DoButtonRequest(sTitle, sText, sDefaultButton, fEnter, fCancel, sEnterButtonText, sCancelButtonText)

	NextRP:QuerryButton(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent, sText, sDefaultButton, sEnterButtonText, fEnter, sCancelButtonText, fCancel)

end