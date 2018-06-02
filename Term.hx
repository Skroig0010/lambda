enum Term{
    TmVar(i : Int);
    TmAbs(t : Term);
    TmApp(t1 : Term, t2 : Term);
}
