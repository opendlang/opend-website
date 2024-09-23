// just docs: Contract Programming
/++





        Contracts enable specifying conditions that must hold true
        when the flow of runtime execution reaches the contract.
        If a contract is not true, then the program is assumed to have entered
        an undefined state.

        Rationale:         Building contract support into the language provides:

        $(NUMBERED_LIST
        * a consistent look and feel for the contracts
        * tool support
        * the implementation can generate better code using information gathered
        from the contracts
        * easier management and enforcement of contracts
        * handling of contract inheritance
        
)
        

$(HTMLTAG3V img, src="images/d4.gif" style="max-width:100%" alt="Contracts make D bug resistant" border="0")

$(H2 $(ID assert_contracts) Assert Contract)

        See [expression#AssertExpression|expression, AssertExpression].

$(H2 $(ID pre_post_contracts) Pre and Post Contracts)

        See:
$(LIST
* $(LINK2 spec/function#preconditions,`in` contracts).
* $(LINK2 spec/function#postconditions,`out` contracts).



)
$(H2 $(ID Invariants) Invariants)

        See $(LINK2 spec/struct#Invariant,Struct Invariants) and $(LINK2 spec/class#invariants,Class Invariants).


$(H2 $(ID references) References)

        $(LIST
*         $(LINK2 https://web.archive.org/web/20080919174640/http://people.cs.uchicago.edu/~robby/contract-reading-list/, Contracts Reading List)
*         $(LINK2 http://jan.newmarch.name/java/contracts/paper-long.html, Adding Contracts to Java)
        

)

template-mixin, Template Mixins, version, Conditional Compilation




Link_References:
	ACC = Associated C Compiler
+/
module contracts.dd;