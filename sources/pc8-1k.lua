p,pc,ac,la,su,ca,ct=0,1,0,0,1,0,0
function s(s)n=tonum(s) return n and n or 0 end 
function ed(n)return n end 
function _init()
up={{n="ram",t="p",l=0,d={{v=1,c=10},{v=2,c=200},{v=4,c=1000}}},
{n="hdd",l=0,t="a",d={{v=0.1,c=50},{v=0.2,c=500},{v=0.5,c=2000}}},
{n="cpu",t="p",l=0,d={{v=2,c=400},{v=5,c=1250},{v=10,c=5000}}},
{n="gpu",t="a",l=0,d={{v=0.5,c=500},{v=1,c=2500},{v=2,c=10000}}},
{n="you",t="b",l=0,d={{v=3,c=1500},{v=8,c=6000},{v=20,c=25000}}}}
end 
function _update60()
if btnp(0)then p=min(32000,p+pc) ct,ca=1,10 end 
if btnp(1)then p=min(32000,p+pc) ct,ca=2,10 end 
if btnp(2)then su=max(1,su-1)end 
if btnp(3)then su=min(#up,su+1)end 
if btnp(4)then b(su)end 
if ac>0 then 
t=time()td=t-la tp=flr(ac*td*10)/10
if tp>0 then p=min(32000,p+tp*pc) la=t 
if ca<=0 then ca,ct=5,0 end end end 
if ca>0 then ca-=1 end 
end 
function b(i)
uu=up[i]if uu.l>=3 then return end 
l=uu.l+1 co=uu.d[l].c 
if p>=co then p=p-co uu.l+=1 r()end 
end 
function r()
pc,ac=1,0 
for uu in all(up)do 
if(uu.t=="p"or uu.t=="b")and uu.l>0 then 
l=uu.l pc=pc+uu.d[l].v end 
if(uu.t=="a"or uu.t=="b")and uu.l>0 then 
l=uu.l ac=min(100,ac+ed(uu.d[l].v))end end 
end 
function _draw()
cls(0)print("clicker",5,5,9)
if p < 32000 then print("bytes: "..flr(p),5,15,12) else print("bytes: INFINITE",5,15,8) end
print("+"..pc.." per click",5,25,11)
dr()du()
if ac>0 then ad=ac>=1 and flr(ac*10)/10 or ac 
print("auto: "..ad.."/s",5,35,9)end 
end 
function dr()
x,y,bs=40,64,8 
if ca>0 then sz=bs+ca dch(x,y,sz,11)
print("click",x-9,y-2,7)else dp(x,y,bs)end 
end 
function dp(x,y,sz)
w,h=sz+2,sz rectfill(x-w,y-h,x+w,y+h,6)
rectfill(x-w+1,y-h+1,x+w-1,y+h-1,0)
rectfill(x-2,y+h,x+2,y+h+2,13)
end 
function dch(x,y,sz,cc)
rectfill(x-sz,y-sz,x+sz,y+sz,cc)
rectfill(x-sz+1,y-sz+1,x+sz-1,y+sz-1,1)
end 
function du()
rectfill(85,5,127,123,1)rect(85,5,127,123,7)
print("upgrades",88,8,7)ys=17 
for i=1,#up do y=ys+(i-1)*22 uu=up[i]cl=6 
if i==su then rect(86,y-2,126,y+18,7)cl=7 end 
print(uu.n,88,y,cl)print(uu.l,88,y+5,cl-1)
if uu.l<3 then cst=uu.d[uu.l+1].c
print(cst,88,y+10,cl-1)else print("max",88,y+10,10)end end 
end
