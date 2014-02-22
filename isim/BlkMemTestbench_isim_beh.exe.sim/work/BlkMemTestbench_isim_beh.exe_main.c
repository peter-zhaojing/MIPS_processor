/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    xilinxcorelib_ver_m_00000000001358910285_1984803370_init();
    xilinxcorelib_ver_m_00000000001358910285_3383635145_init();
    xilinxcorelib_ver_m_00000000001687936702_3840004403_init();
    xilinxcorelib_ver_m_00000000000277421008_4105561834_init();
    xilinxcorelib_ver_m_00000000001485706734_2637466124_init();
    work_m_00000000002570770929_1750560174_init();
    work_m_00000000002771406470_2295160528_init();
    work_m_00000000004134447467_2073120511_init();


    xsi_register_tops("work_m_00000000002771406470_2295160528");
    xsi_register_tops("work_m_00000000004134447467_2073120511");


    return xsi_run_simulation(argc, argv);

}
