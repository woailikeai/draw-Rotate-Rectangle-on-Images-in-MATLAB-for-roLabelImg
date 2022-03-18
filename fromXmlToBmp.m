%在一个本文件所在的含有若干xml文件和若干bmp文件的文件夹中，将xml文件中的信息绘制在bmp文件上
%使用时，将fromXmlToBmp、drawPolygon、drawRectFill、imageOnImage、tlbr2cntHV五个文件放在需要处理的文件内，运行fromXmlToBmp文件
%drawPolygon、drawRectFill、imageOnImage、tlbr2cntHV来自github用户Kamitani Lab
%https://github.com/KamitaniLab/imageGeneration_MATLAB
clc%清除命令行窗口中的所有文本，让屏幕变得干净
clear%从当前工作区中删除所有变量，并将它们从系统内存中释放
%使用时需要更改
videoOrder = 11 ;%对应视频的视频序号
%使用时需要更改
fileNum = 200 ;%文件夹中的xml文件个数
%使用时需要更改
colorOfRotateRectangle =10000;%旋转矩形框的填充颜色，数值越大颜色越深
for i = 1 : fileNum
    xmlName = '%d%d.xml';%设置单个xml文件名格式
    xmlName = sprintf(xmlName,videoOrder,i);%将视频序号和循环中的i转换为字符，组成文件名
    xmlFile = xmlread(xmlName);%读取xml文件
    bmpName = '%d%d.bmp';%设置单个bmp文件名格式
    bmpName = sprintf(bmpName,videoOrder,i);%将视频序号和循环中的i转换为字符，组成文件名
    bmpFile = imread(bmpName);%读取bmp文件
    xmlFileRoot = xmlFile.getDocumentElement();%获取单个xml文件的根节点
    xmlFileObject = xmlFileRoot.getElementsByTagName('object');%获取单个xml文件中的object节点集合
    xmlFileObjectNum = xmlFileObject.getLength();%获取单个xml文件中的的object节点的个数
    for j = 0 : (xmlFileObjectNum-1)
        objectJ=xmlFileObject.item(j);%从object节点的集合中获取第j个objec节点
        objectJCX=char(objectJ.item(11).item(1).getTextContent());%获取第j个object节点中的cx属性
        objectJCY=char(objectJ.item(11).item(3).getTextContent());%获取第j个object节点中的cy属性
        objectJW=char(objectJ.item(11).item(5).getTextContent());%获取第j个object节点中的w属性
        objectJH=char(objectJ.item(11).item(7).getTextContent());%获取第j个object节点中的h属性
        objectBndboxItemNum=objectJ.item(11).getLength();%获取单个object节点中的bndbox子节点中的属性个数
        if objectBndboxItemNum==11%数据标注为旋转框，包含角度信息
            objectJAngle=char(objectJ.item(11).item(9).getTextContent());%获取第j个object节点中的angle属性
            cx=str2double(objectJCY);%画旋转矩形时，cx为转换为double的objectJCY
            cy=str2double(objectJCX);%画旋转矩形时，cy为转换为double的objectJCX
            w=str2double(objectJH);%画旋转矩形时，w为转换为double的objectJH
            h=str2double(objectJW);%画旋转矩形时，h为转换为double的objectJW
            angle=str2double(objectJAngle);%画旋转矩形时，angle为转换为double的objectAngle
            %调用自己的函数turnXmlIntoRotateRectangle，计算objectJ的四点坐标
            [rotateRectangleX1,rotateRectangleY1,rotateRectangleX2,rotateRectangleY2,rotateRectangleX3,rotateRectangleY3,rotateRectangleX4,rotateRectangleY4]= turnXmlIntoRotateRectangle(cx,cy,w,h,angle);
            %调用画旋转矩形
            rotateRectangleObjectJ=drawPolygon(bmpFile,[rotateRectangleX1,rotateRectangleY1;rotateRectangleX2,rotateRectangleY2;rotateRectangleX3,rotateRectangleY3;rotateRectangleX4,rotateRectangleY4],colorOfRotateRectangle);
            %将旋转矩形存入图片
            imwrite(rotateRectangleObjectJ,bmpName);
            %存入矩形框后重新读取图片
            bmpFile = imread(bmpName);
        else%数据标注为水平矩形框，不包含角度信息
            xmin=str2double(objectJCY);%画水平矩形时，xmin为转换为double的objectJCY
            ymin=str2double(objectJCX);%画水平矩形时，ymin为转换为double的objectJCX
            xmax=str2double(objectJH);%画水平矩形时，xmax为转换为double的objectJH
            ymax=str2double(objectJW);%画水平矩形时，ymax为转换为double的objectJW
            %调用画水平矩形
            normalRectangleObjectJ=drawRectFill(bmpFile,[xmin ymin xmax ymax],colorOfRotateRectangle);
            %将水平矩形存入图片
            imwrite(normalRectangleObjectJ,bmpName);
            %存入矩形框后重新读取图片
            bmpFile = imread(bmpName);
        end
    end
end
%定义函数turnXmlIntoRotateRectangle，输入车辆中心坐标cx,cy,宽度w，长度h，航向角angle(弧度)，输出旋转矩形框的四个点的坐标的八个值
function [rotateRectangleX1,rotateRectangleY1,rotateRectangleX2,rotateRectangleY2,rotateRectangleX3,rotateRectangleY3,rotateRectangleX4,rotateRectangleY4]= turnXmlIntoRotateRectangle(cx,cy,w,h,angle)
    rotateRectangleX1=cx-0.5*w*cos(angle)-0.5*h*sin(angle);
    rotateRectangleY1=cy+0.5*w*sin(angle)-0.5*h*cos(angle);
    rotateRectangleX2=cx+0.5*w*cos(angle)-0.5*h*sin(angle);
    rotateRectangleY2=cy-0.5*w*sin(angle)-0.5*h*cos(angle);
    rotateRectangleX3=cx+0.5*w*cos(angle)+0.5*h*sin(angle);
    rotateRectangleY3=cy-0.5*w*sin(angle)+0.5*h*cos(angle);
    rotateRectangleX4=cx-0.5*w*cos(angle)+0.5*h*sin(angle);
    rotateRectangleY4=cy+0.5*w*sin(angle)+0.5*h*cos(angle);
end
