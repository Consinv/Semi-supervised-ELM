clear all
close all
disp('The only input needed is a distance matrix file')
disp('The format of this file should be: ')
disp('Column 1: id of element i')
disp('Column 2: id of element j')
disp('Column 3: dist(i,j)')
mdist=importdata('example_distances.dat');
disp('Reading input distance matrix')
xx=mdist;%xx����������ľ������ݣ���ʽ����1����2����12��ľ���
ND=max(xx(:,2));
NL=max(xx(:,1));
if (NL>ND)
  ND=NL;%ND����������������Ҳ�������ݵĸ���
end
N=size(xx,1);%N��xx������
%%�������������ɾ������dist������������������������������������
for i=1:ND
  for j=1:ND
    dist(i,j)=0;%�γ�һ��ȫ0��ND*ND����dist
  end
end
for i=1:N
  ii=xx(i,1); 
  jj=xx(i,2);
  dist(ii,jj)=xx(i,3);%��xx�ĵ������Ǿ������ݣ��ӵ�dist������
  dist(jj,ii)=xx(i,3);%dist�Ǹ�б�Գƾ���
end
%����������ѡȡ�ضϾ���dc������������������������������������
percent=2.0;%ȡ�ٷ�֮��Ϊ�ضϾ��룬dc
fprintf('average percentage of neighbours (hard coded): %5.6f\n', percent);

position=round(N*percent/100);%����������������ֵ
sda=sort(xx(:,3));%Ԫ����������
dc=sda(position);

fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);%����Rho���˹�˵İ뾶

%ȫ0��ʼ��rho����������rho���ܶ�
for i=1:ND
  rho(i)=0.;
end
%
% Gaussian kernel��ԭ��G(x)=e^(-x^2)
%
for i=1:ND-1
  for j=i+1:ND
     rho(i)=rho(i)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
     rho(j)=rho(j)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
  end
end%�������£���i�̶�������jԽ��Խ��
%
% "Cut off" kernel�ض��ں�
%����i������i������j֮�����С��dc�ĸ���
%����j����Ϊj��i�󣬵��ȶ�j��ʱ��ǰ���Ѿ��ȶԹ�

%����������������������������������������������������������
%����i=1,j=2��ʱ�����dist(1,2)�ȽضϾ������ôrho(j)�Լ�
%��Ϊ��i=2ʱ���Ƚ϶����j=3��ʼ

%for i=1:ND-1
%  for j=i+1:ND
%    if (dist(i,j)<dc)
%       rho(i)=rho(i)+1.;
%       rho(j)=rho(j)+1.;
%    end
%  end
%end

maxd=max(max(dist));%������������ֵ��Ҳ����������

[rho_sorted,ordrho]=sort(rho,'descend');%�Ӵ�С�������У�rho_sorted��������������ordrho�Ƕ�Ӧ�Ӵ�С���е��ܶȱ��
delta(ordrho(1))=-1.;%��%�����õĽضϺˣ�rho��С�ڽضϾ�����ھ��������ܶȡ����������delta������Ϊ-1��������Ϊ��С����

nneigh(ordrho(1))=0;%���������ı��

%���ܶȱ��Լ����Ҿ�����̵ĵ㣬delta������룬nneigh������
for ii=2:ND
   delta(ordrho(ii))=maxd;%ÿ��ѭ����ʼ���ҵ����ֵ
   for jj=1:ii-1
     if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))%�ڱ��Լ��ܶȴ�ĵ����Ҿ�����̵�
        delta(ordrho(ii))=dist(ordrho(ii),ordrho(jj));%deltaȡСֵ
        nneigh(ordrho(ii))=ordrho(jj);
     end
   end
end
delta(ordrho(1))=max(delta(:));%ȡ���������ֵ
disp('Generated file:DECISION GRAPH')%���ɾ���ͼ�ļ�������ܶȺ�delta����
disp('column 1:Density')
disp('column 2:Delta')

fid = fopen('DECISION_GRAPH', 'w');
for i=1:ND
   fprintf(fid, '%6.2f %6.2f\n', rho(i),delta(i));
end

disp('Select a rectangle enclosing cluster centers')%ѡ��Χ�ƾ������ĵľ���
scrsz = get(0,'ScreenSize');%��ȡ���Էֱ��ʣ�����������Ļ��ȣ����ĸ�����Ļ�߶�
figure('Position',[6 72 scrsz(3)/4. scrsz(4)/1.3]);%position���ԣ�[left bottom width height]��ǰ������ԭ������λ��
%��ʼ��ind������٤��ֵ
for i=1:ND
  ind(i)=i;
  gamma(i)=rho(i)*delta(i);
end
subplot(2,1,1)%��������ͼ�����ǵ�һ��
%��ͼ������ȡ���tt��o�ͣ�k����ɫ��Marksize����ʶ����С��Markfacecolor����ʶ�������ɫ��markeredgecolor����ʶ����Ե��ɫ
tt=plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')


subplot(2,1,1)%�ڶ���
rect = getrect(1);%�ӵ�һ��ͼ�л�ȡ���ξ��󣬰���xmin,ymin,widht,height
rhomin=rect(1);%rhoΪx�ᣬ��������Сֵ
deltamin=rect(2);
NCLUST=0;%��������
for i=1:ND%��ʼ��c1����
  cl(i)=-1;
end
for i=1:ND
  if ( (rho(i)>rhomin) && (delta(i)>deltamin))%ͳ�����ݵ�rho��delta��������Сֵ�õ㣬�Ծ��ο������Ϊ�߽�
     NCLUST=NCLUST+1;
     cl(i)=NCLUST;%�������ĵı�ţ�Ҳ����������һ��
     icl(NCLUST)=i;%nclust������ı��
  end
end
fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);%Ⱥ����
disp('Performing assignation')%ִ�з���

%assignation
for i=1:ND
  if (cl(ordrho(i))==-1)%=-1˵�����Ǵ�������
    cl(ordrho(i))=cl(nneigh(ordrho(i)));%����������������ܶȱ������࣬��rho������˳��ֵ��������ִ���
  end
end
%��ʼ��halo����⻷���֣�����
for i=1:ND
  halo(i)=cl(i);
end
if (NCLUST>1)%���������Ŀ����1 
  for i=1:NCLUST%��ʼ��bord_rho����
    bord_rho(i)=0.;
  end
  %���������������������濪ʼ��ѡ�߽����򡣡�������������
  %���жԱ߽�Ķ��壺�Ǵ���㣬����������������ݵ�ľ���С��dc
  %Ȼ���ڱ߽��ҳ��ܶ����ĵ㣬�ܶȶ���Ϊpd
  %���д�������ܶȵ�Ϊ������ģ�С������ܶȵ�Ϊ���Σ�������
  for i=1:ND-1
    for j=i+1:ND
      if ((cl(i)~=cl(j))&& (dist(i,j)<=dc))%��ÿ�����ݵ�i�жϿɷ��Ϊ�߽�㣬������Ծͼ�¼һ��ƽ���ܶ�
        rho_aver=(rho(i)+rho(j))/2.;
        if (rho_aver>bord_rho(cl(i))) %��ƽ���ܶ��Ƿ�ɻ��ֺ��ĺ�����,������ܶ�
          bord_rho(cl(i))=rho_aver;
        end
        if (rho_aver>bord_rho(cl(j))) 
          bord_rho(cl(j))=rho_aver;
        end
      end
    end
  end
  for i=1:ND
    if (rho(i)<bord_rho(cl(i)))%С�ڻ����ܶȣ����ж�Ϊ������halo����Ϊ0
      halo(i)=0;
    end
  end
end
for i=1:NCLUST%��ÿ���������
  nc=0;%����Ԫ�ظ���
  nh=0;%���к��ĸ���
  for j=1:ND
    if (cl(j)==i) %����Ԫ�ظ���
      nc=nc+1;
    end
    if (halo(j)==i)%��������� 
      nh=nh+1;
    end
  end
  fprintf('CLUSTER: %i CENTER: %i ELEMENTS: %i CORE: %i HALO: %i \n', i,icl(i),nc,nh,nc-nh);
end

cmap=colormap;%��ȡһ��ͼ����ɫ�壬����һ��64*3�ľ���ȱʡֵ�����
for i=1:NCLUST
   ic=int8((i*64.)/(NCLUST*1.));%ic����ɫ���ã�ѡ��64��ĳһ�У���ֻ�ܻ���64�಻ͬ����ɫ��
   subplot(2,1,1)
   hold on
   plot(rho(icl(i)),delta(icl(i)),'o','MarkerSize',8,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
end
subplot(2,1,2)%���ƾ���ͼ
disp('Performing 2D nonclassical multidimensional scaling')
Y1 = mdscale(dist, 2, 'criterion','metricstress');%mdscale�Ƿ������߶ȱ仯
plot(Y1(:,1),Y1(:,2),'o','MarkerSize',2,'MarkerFaceColor','k','MarkerEdgeColor','k');%�������е�Ϊ��ɫ�㣬֮�����ȥ
title ('2D Nonclassical multidimensional scaling','FontSize',15.0)
xlabel ('X')
ylabel ('Y')
for i=1:ND%��ʼ��ND*2��A����
 A(i,1)=0.;
 A(i,2)=0.;
end
for i=1:NCLUST
  nn=0;
  ic=int8((i*64.)/(NCLUST*1.));%��ÿ������ȷ��һ����ɫ����ic����cmapĳһ��
  for j=1:ND%���ƴ�����ģ�halo��Ϊ0�ľ��Ǵ�����ģ��ø���ɫ����
    if (halo(j)==i)
      nn=nn+1;
      A(nn,1)=Y1(j,1);
      A(nn,2)=Y1(j,2);
    end
  end
  hold on
  plot(A(1:nn,1),A(1:nn,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
end

%for i=1:ND
%   if (halo(i)>0)
%      ic=int8((halo(i)*64.)/(NCLUST*1.));
%      hold on
%      plot(Y1(i,1),Y1(i,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
%   end
%end
faa = fopen('CLUSTER_ASSIGNATION', 'w');
disp('Generated file:CLUSTER_ASSIGNATION')
disp('column 1:element id')
disp('column 2:cluster assignation without halo control')
disp('column 3:cluster assignation with halo control')
for i=1:ND
   fprintf(faa, '%i %i %i\n',i,cl(i),halo(i));
end
