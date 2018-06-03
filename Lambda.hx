import haxe.io.*;

class Lambda{
    var input : Input = Sys.stdin();
    var output : Output = Sys.stdout();
    public function new(){}

    public function printtm(t : Term){
        switch(t){
            case TmAbs(t) :
                output.writeString("(\\"); 
                output.writeString(".");
                printtm(t);
                output.writeString(")");
            case TmApp(t1, t2) :
                output.writeString("(");
                printtm(t1);
                output.writeString(" ");
                printtm(t2);
                output.writeString(")");
            case TmVar(i) :
                output.writeString(Std.string(i));
        }
    }

    function termShift(d : Int, t : Term) : Term{
        var walk : Int -> Term -> Term = null;
        walk = function(c : Int, t : Term) : Term{
            return switch(t){
                case TmVar(i) : if(i >= c) {
                    TmVar(i + d);
                }else{
                    TmVar(i);
                }
                case TmAbs(t) : TmAbs(walk(c + 1, t));
                case TmApp(t1, t2) : TmApp(walk(c, t1), walk(c, t2));
            }
        }
        return walk(0, t);
    }

    function termSubst(j, s, t) : Term{
        var walk : Int -> Term -> Term = null;
        walk = function(c : Int, t : Term) : Term{
            return switch(t){
                case TmVar(i) : if(i == j + c) termShift(c, s) else TmVar(i);
                case TmAbs(x) : TmAbs(walk(c + 1, t));
                case TmApp(t1, t2) : TmApp(walk(c, t1), walk(c, t2));
            }
        }
        return walk(0, t);
    }

    function termSubstTop(s : Term, t : Term) : Term{
        return termShift(-1, termSubst(0, termShift(1, s), t));
    }

    function isVal(t : Term) : Bool{
        return switch(t){
            case TmAbs(_) : true;
            default : false;
        }
    }

    function eval1(t : Term) : Term{
        return switch(t){
            case TmApp(TmAbs(t12), v2) if(isVal(v2)) :
                termSubstTop(v2, t12);
            case TmApp(v1, t2) if(isVal(v1)) :
                var t22 = eval1(t2);
                TmApp(v1, t22);
            case TmApp(t1, t2) :
                var t12 = eval1(t1);
                TmApp(t12, t2);
            default : throw new NoRuleApplies();
        }
    }

    function eval2(t : Term) : Term{
        return switch(t){
            case TmApp(t1, t2) :
                switch((eval2(t1))){
                    case TmAbs(t12) : termSubstTop(eval2(t2), t12);
                    default : throw new NoRuleApplies();
                }
            case TmAbs(t) : TmAbs(t);
            default : throw new NoRuleApplies();
        }
    }

    public function eval(t :Term) : Term{
        try{
            var t1 = eval1(t);
            return eval(t1);
        }catch(n : NoRuleApplies){
            return t;
        }
    }

    public function eval_v2(t : Term) : Term{
        try{
            var t1 = eval2(t);
            return t1;
        }catch(n : NoRuleApplies){
            return t;
        }
    }

    static public function main(){
        var lambda = new Lambda();
        var v = new Parser(lambda.input.readLine()).getTerm();
        lambda.printtm(v);
        lambda.output.writeString("\n" + "eval : ");
        lambda.printtm(lambda.eval(v));
        lambda.output.writeString("\n" + "eval_v2 : ");
        lambda.printtm(lambda.eval_v2(v));
        lambda.output.writeString("\n");
    }
}

private class NoRuleApplies{
    public function new(){}
}
