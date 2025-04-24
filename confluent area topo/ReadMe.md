# How to use
1.下载https://github.com/bhqasx/matlab-tools-for-calibration/tree/master/RiverGeoAnalysis  
打开matlab进入RiverGeoAnalysis，运行  
`CS=CS_to_AbsCoordi;`  
当弹出文件选择框时，选择./confluent area topo/中的示例文件：CS_for_XyCompute3.txt  
弹出以下窗口时，依次输入2,3,4  
![image](https://github.com/user-attachments/assets/15085d9b-0ce1-4817-9125-a431fa8a5f34)  
提示need to see surf plot? y/n时，输入n  
  
2.将matlab工作目录切换回./MeshGenerator_SWE/confluent area topo，运行  
`[ p,t,zb,pgxy,x_shape,y_shape ] = confluent_area_topo( CS,  324.37, 0.4, 50 );`  

3.工作目录切换到./MeshGenerator_SWE，运行  
`[vol,A]=Vol_A_UnderZ(p,t,zb,[pgxy.x,pgxy.y],330)`  
就可以得到330m下容积，如果一切顺利，结果vol应为1.2087e+07，后续请自行使用循环语句计算所有水位下的容积
