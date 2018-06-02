class Parser{
    var cnt = 0;
    var text : String;
    public function new(text : String){
        this.text = text;
    }

    public function getTerm() : Term{
        return switch(text.charAt(cnt)){
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" :
                getInt();
            case "(" :
                cnt++;
                switch(text.charAt(cnt)){
                    case "\\" :
                        cnt+=2; // \.を消費
                        var t = getTerm();
                        cnt++; // )を消費
                        TmAbs(t);
                    default :
                        var t1 = getTerm();
                        cnt++; // 半角スペースを消費
                        var t2 = getTerm();
                        cnt++; // )を消費
                        TmApp(t1, t2);
                }
            default :
                throw "unknown identifier " + text.charAt(cnt) + " at " +cnt;

        }
    }

    function getInt() : Term{
        var num = "";
        var reg = ~/[0-9]/;

        while(text.charAt(cnt) != ""){
            if(!reg.match(text.charAt(cnt))){
                break;
            }
            num += text.charAt(cnt);
            cnt++;
        }
        return TmVar(Std.parseInt(num));
    }
}
