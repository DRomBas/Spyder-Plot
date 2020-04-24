close all;clc;clearvars;

N = 160;
M = 20;
Data = 18+1*randn(1,M) + 2.*randn(N,M);

% Example 1
subplot(121);
spiderPlot(Data)

% Example 2
subplot(122);
param.plotDots = false;
param.superior = 90;
param.inferior = 10;
spiderPlot(Data,param)