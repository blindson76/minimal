#include <stdio.h>
#include <hivex.h>
int main(){
    hive_h *hv = hivex_open ("/nfss/EFI/Microsoft/Boot/BCD", 0);
    return 0;
}