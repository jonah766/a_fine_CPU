package datatypes;

    function automatic int max(int a, int b);
        return (a > b) ? a : b;
    endfunction

    function automatic int min(int a, int b);
        return (a < b) ? a : b;
    endfunction

endpackage