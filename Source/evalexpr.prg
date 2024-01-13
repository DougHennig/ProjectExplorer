lparameters tcExpression
local lcExpression
lcExpression = tcExpression
if left(tcExpression, 1) = '{'
	try
		lcExpression  = evaluate(substr(tcExpression, 2, ;
			len(tcExpression) - 2))
	catch
	endtry
endif left(tcExpression, 1) = '{'
return lcExpression
