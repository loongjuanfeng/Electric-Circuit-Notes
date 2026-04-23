#import "../../libs.typ": *

#show: ilm.with(
  title: [Electric Circuit],
  date: datetime.today(),
  author: "Junfeng Lve",
  abstract: [Study notes on chips in _Digital Fundamentals_, Thomas L. Floyd.],
)
#show: setup

= Adders

#image("/assets/image-4.png")

#image("/assets/image-2.png")

#overview[4位并行加法器的功能][
  把两组4位二进制数与一个低位进位一起相加，输出4位和与一个最高位进位。
]

图中芯片本质上就是把4个全加器封装在一起，所以最核心的掌握要求不是死记引脚编号，而是记住它的整体作用：

A3 A2 A1 A0 + B3 B2 B1 B0 + C0

输出写成C4 S3 S2 S1 S0。

其中，C0是输入进位，C4是输出进位。做题时只要能认出"2组4位输入 + 1个进位输入 + 4位和 + 1个进位输出"，就能判断这是4位并行加法器。

#definition[输入与输出][
  + 输入：A0到A3、B0到B3、C0
  + 输出：S0到S3、C4
]

#note[并行的含义][
  A组与B组的4个数位同时送入芯片，但进位仍按从低位到高位逐级传递。
]

因此，"并行"说的是4位同时参与运算，不是说4位之间彼此完全独立。最低位先和输入进位C0相加，再把产生的进位继续送到更高位，最后在最高位得到总进位C4。

#method[按位理解][
  + 第0位：A0、B0、C0相加，得到S0，并产生向高位的进位
  + 第1位：A1、B1再加上前一位进位，得到S1
  + 第2位：同理得到S2
  + 第3位：同理得到S3，并给出最终进位C4
]

所以可以把它记成一句话：*低位吃进位，高位吐进位，中间给出4位和。*

#example[最简单的识别方式][
  先找两个特殊端：进位输入C0和进位输出C4。
]

找到这两个端后，剩下的信号通常就容易分组了：两组是被加数 $A$、$B$，一组是和输出 $S$。考试若给出管脚对应图，通常就是要你先把这三类信号分清，再判断芯片功能。

#strategy[速记句][
  4位并行加法器 = 两个4位数 + 一个输入进位，得到一个4位和 + 一个输出进位。
]

#remark[为什么输出有5位信息][
  两个4位数相加，结果可能超过4位，所以除了S0到S3以外，还必须有一个最高位进位C4。
]

例如，1111 + 0001 = 1 0000。这时低4位和是0000，而最高位进位就是1，因此不能只看4位和，必须同时看C4。

#connection[级联用途][
  若要实现8位或更高位加法，可把前一级的C4接到后一级的C0。
  #image("/assets/image-3.png")
]

这说明4位并行加法器不仅能单独完成4位加法，也能作为更大位数加法器的基本模块。

#summary[考试时真正要记住的点][
  + 它的功能是做二进制加法，不是做译码或寄存
  + 它有两组4位输入，一个进位输入，一个4位和输出，一个进位输出
  + 最低位从C0开始，最高位最后给出C4
  + 看到 $A$、$B$、$S$ 三组信号再加两个进位端，基本就能认出它
]

== Ripple Carry Adder

#image("/assets/image-5.png")

#overview[串行传递进位的加法器][
  ripple carry adder的特点是：每一位的进位都要等低一位先算出来，再继续往高位传。
]

它本质上就是把多个全加器按位串接起来。第0位先根据A0、B0和输入进位C0算出S0与C1；第1位再利用C1算出S1与C2；这样一级一级向上推进，直到最高位。

#definition[为什么叫Ripple][
  进位不是一下子同时出现，而是像波纹一样从低位逐级传到高位。
]

#image("/assets/image-6.png")

#connection[由4位器件级联得到更高位][
  若把两个4位并行加法器首尾相接，前一级的C4接后一级的C0，就能组成8位的ripple carry adder。
]

这正是前一节"4-bit parallel adder"的直接应用。低4位模块先算出自己的进位输出，再把这个进位送给高4位模块，因此整个8位加法器虽然是"并行输入"，但进位路径仍然是"串行等待"。

#image("/assets/image-7.png")

#note[它的主要缺点][
  结构简单，但速度慢。位数越多，等待进位逐级传递的时间越长。
]

做题时要抓住最坏情况：如果低位不断产生或传递进位，那么最高位必须等前面所有级都稳定后，自己的和与进位才能最终确定。因此，ripple carry adder的关键代价就是*进位延迟会累加*。

#strategy[考试速记][
  ripple carry adder = 结构最简单的多位加法器，但高位必须等待低位进位一级一级传上来。
]

#summary[这一节要记住的点][
  + 它由多个全加器或多个4位加法器级联而成
  + 低位进位传给高位，所以计算顺序受进位链限制
  + 优点是结构简单、容易实现
  + 缺点是位数一多，延迟明显变大
]

== Look Ahead Carry Adder

#image("/assets/image-8.png")

#overview[提前算出各级进位][
  look ahead carry adder的核心不是改变求和公式，而是想办法不再傻等低位进位一级一级传递。
]

ripple carry adder的缺点是进位延迟随位数线性增长。look ahead carry adder正是为了解决这个问题而设计的。

它的基本思路是：先根据每一位的输入，判断这一位是会*产生进位*，还是会*传递进位*，然后直接把后面几级所需的进位一次算出来。这样高位就不用等前一级慢慢传了。

#definition[产生与传递][
  + 产生进位：若某位本身就足以形成进位，则这一位会直接给出进位
  + 传递进位：若某位本身不直接产生新进位，但会把低位送来的进位继续传上去
]

教材中常把这两个量分别记成 $G$ 和 $P$。记忆时不必先死抠公式，先抓住含义：*$G$ 决定"自己能不能生进位"，$P$ 决定"别人的进位能不能穿过去"。*

#method[为什么更快][
  + Ripple Carry：先算出C1，再算C2，再算C3
  + Look Ahead：利用输入信号直接写出C1、C2、C3、C4
]

因此，look ahead carry adder把原来"逐级等待"的问题，变成了"组合逻辑直接展开"的问题。代价是电路更复杂，但速度明显提高。

#example[最核心的第一步公式][
  第1级进位可写成
  C1 = G0 + P0 C0
]

这句话很好理解：第0位的输出进位，要么来自它自己直接产生的进位G0，要么来自它把输入进位C0传上去。再往后的C2、C3、C4也能按同样思路继续展开，所以不必一位一位等。

#remark[与Ripple Carry的本质区别][
  ripple carry是"等进位传过来"，look ahead carry是"先把进位算出来"。
]

#strategy[考试速记][
  look ahead carry adder = 用更复杂的组合逻辑换取更快的进位速度。
]

#summary[这一节要记住的点][
  + 它的目标是减少进位链造成的延迟
  + 核心思想是提前判断每一位的进位产生与进位传递
  + 高位进位可由输入直接组合得到，而不必逐级等待
  + 优点是速度快，缺点是电路更复杂
]

= Comparators

#image("/assets/image-9.png")

#overview[比较器的功能][
  比较器用来判断两个二进制数的大小关系，输出结果通常只有三种：$A gt B$、$A = B$、$A lt B$。
]

加法器输出的是"和"，比较器输出的是"大小关系"。考试中若给出芯片引脚图，只要你看到两组输入加上三种关系输出，通常就应想到比较器。

#definition[最核心的输出][
  + 当 $A gt B$ 时，只有"大于"输出为有效
  + 当 $A eq B$ 时，只有"等于"输出为有效
  + 当 $A lt B$ 时，只有"小于"输出为有效
]

因此，比较器可以记成一句话：*不算和，只判大小。*

#image("/assets/image-10.png")

#method[比较大小时先看哪一位][
  比较两个多位二进制数时，应先看最高位；只有最高位相等时，才继续比较下一位。
]

这和十进制比较完全一样。比如比较 $1010$ 和 $1001$，最高位都为 $1$，继续看下一位；第二位都为 $0$，再继续；第三位一个是 $1$，一个是 $0$，于是立刻能判断前者更大，后面的最低位已经不重要了。

#note[为什么最高位最重要][
  二进制数中，位权最大的位最先决定大小关系；只有该位相同，低位才有机会影响结果。
]

所以比较器内部虽然也会看每一位，但思路上应记成：*高位先定胜负，相等再看低位。*

#image("/assets/image-11.png")

#overview[4位比较器芯片怎么认][
  常见的4位比较器芯片输入两组4位数A0到A3、B0到B3，输出三种比较结果：A > B、A = B、A < B。
]

识别芯片时先认出三类信号：

#definition[4位比较器的识别抓手][
  + 两组4位输入：$A$ 组与 $B$ 组
  + 三个结果输出：大于、等于、小于
  + 若还有三个同名输入，多半是给级联用的扩展输入
]

一旦看到"三个关系输出"，它就和前面的加法器很好区分了：加法器会有和位与进位，比较器则没有和位，只有关系判断。

#image("/assets/image-12.png")

#connection[为什么会有级联输入][
  为了比较8位、16位等更大的二进制数，4位比较器通常还带有"大于输入""等于输入""小于输入"，用于把低位比较结果送到高位模块。
]

它的思想和前面的级联加法器有些类似，但传递的不是进位，而是"低位已经比较出的关系"。若高4位已经能分出大小，则直接由高4位决定；若高4位相等，则要参考低4位送来的结果。

#remark[单片使用时怎么接][
  若只用一个4位比较器单独比较4位数，通常应把"等于输入"置为 $1$，把"大于输入"和"小于输入"置为 $0$。
]

这样设置的含义是：在更低位还不存在的情况下，先假定两数此前相等，然后由本片自己判断最终关系。这是考试里很容易考的点。

#strategy[考试速记][
  4位比较器 = 两组4位输入，输出三种关系；单片使用时默认"先当作前面相等"。
]

#summary[这一节要记住的点][
  + 比较器的任务是判断 $A gt B$、$A = B$、$A lt B$
  + 比较多位数时先看最高位，相等再逐位往下看
  + 识别芯片时先抓两组输入和三种关系输出
  + 若芯片还有三种关系输入，说明它支持级联扩展
  + 单片使用时常设"等于输入 = 1，大于输入 = 0，小于输入 = 0"
]

= Decoders

#image("/assets/image-13.png")

#overview[译码器的功能][
  译码器把输入的二进制代码转换成某一条特定输出线的有效信号。
]

加法器和比较器都是对数值做运算或判断，译码器则不同——它的任务是把"输入代码"翻译成"被选中的一路输出"，可以理解成一个 *代码到线路* 的转换器。

#definition[最基本的结构特征][
  + 有若干位输入，表示一个二进制代码
  + 有较多条输出线，对应可能的译码结果
  + 某一时刻通常只有一条输出线被选中
]

若输入有 $n$ 位，则最典型的译码器可对应 $2^n$ 条输出线。因此，译码器最常见的表达方式就是 "$n$ 线输入，$2^n$ 线输出"。

#image("/assets/image-14.png")

#note[如何理解译码][
  输入的二进制数就像一个编号，译码器负责把这个编号对应到唯一的一条输出线上。
]

例如，输入是某个4位代码时，译码器不会输出一个新的4位数，而是直接把"第几路"选出来。这种功能特别适合做地址选择、设备选择、存储器选通以及数码显示控制。

#remark[考试时先看什么][
  看到一组输入、很多条输出，而且输出不是和位也不是比较关系，就应优先想到译码器。
]

== 1-of-16 Decoder

#image("/assets/image-15.png")

#overview[1-of-16的含义][
  1-of-16 decoder表示：4位输入代码从16条输出线中选出一路。
]

因为 $2^4 = 16$，所以4位输入正好可以对应16种情况。它的功能可以概括成一句话：*4位代码选16路，只让其中一路有效。*

#definition[芯片识别抓手][
  + 4位输入：通常记为 $A, B, C, D$ 或类似名称
  + 16条输出：对应 $0$ 到 $15$ 的16种结果
  + 常见还带使能端，用来决定芯片当前是否工作
]

#image("/assets/image-16.png")

#method[输出是怎样被选中的][
  当输入代码确定后，16条输出中只有与该代码对应的一路被激活，其余输出保持无效状态。
]

#note[使能端与低有效][
  常见的1-of-16译码器往往带有使能输入，而且输出常常采用低有效。
]

这意味着芯片必须先满足使能条件，译码结果才会真正出现在输出端；同时，"被选中"不一定表现为高电平，也可能表现为某一路变为低电平。做题时若图中输出端带反相标记，或名称上带有低有效提示，就要按低有效理解。

#strategy[考试速记][
  1-of-16译码器 = 4位输入决定16路中的哪一路有效；看到使能端时先判断芯片有没有被允许工作。
]

#summary[这一小节要记住的点][
  + 4位输入对应16种状态，所以能选16路输出
  + 一次通常只会有一路输出被选中
  + 识别芯片时先抓4位输入、16路输出和使能端
  + 常见器件常有低有效输出，做题时要先看有效电平定义
]

== BCD-to-Decimal Decoder

#image("/assets/image-17.png")

#overview[BCD到十进制译码][
  BCD-to-decimal decoder把1位十进制数的BCD码翻译成10条十进制输出线中的一路。
]

这里输入虽然也是4位，但它不是拿来表示 $0$ 到 $15$ 的全部二进制状态，而是只表示十进制数字 $0$ 到 $9$ 的BCD码。因此，输出只需要10路，而不是16路。

#definition[它和1-of-16译码器的区别][
  + 1-of-16：4位输入的16种状态都可参与译码
  + BCD-to-Decimal：只关心BCD的 $0000$ 到 $1001$
]

#remark[常见考点][
  教材中的这类器件也常见低有效输出，因此"某数字被选中"可能表现为对应输出为低电平。
]

#strategy[考试速记][
  BCD-to-decimal decoder = 4位BCD输入只译出0到9，共10路输出；不是所有4位代码都当作有效十进制数字。
]

#summary[这一节要记住的点][
  + 译码器的本质是把输入代码翻译成某一路输出
  + 1-of-16译码器是4位输入选16路输出
  + BCD到十进制译码器是4位BCD输入选10路输出
  + 识别芯片时先看输入位数、输出路数、是否有使能端、是否低有效
]

== BCD-to-7-Segment Decoder

#image("/assets/image-18.png")

#overview[它的功能][
  BCD-to-7-segment decoder把1位十进制数的BCD码转换成七段显示器所需的段控制信号。
]

因此，它和前面的BCD-to-decimal decoder不同：前者是从10条数字输出线中选一路，后者则是直接告诉七段数码管的各段该不该亮。记忆时最核心的一句话是：*4位BCD输入，7段显示输出。*

#definition[芯片识别抓手][
  + 输入端通常是4位BCD输入
  + 输出端通常标成 $a, b, c, d, e, f, g$
  + 常见还带控制端，用于测试、消隐或级联控制
]

所以考试若给出管脚图，只要你看到输出端不是 $0$ 到 $9$ 十条线，而是 $a$ 到 $g$ 七条段线，就应优先想到BCD-to-7-segment decoder。

#image("/assets/image-19.png")

例如，显示某个十进制数字时，译码器会根据输入的BCD码，直接给出 $a$ 到 $g$ 七段的开关状态。

#note[和前一小节的区别][
  BCD-to-decimal decoder是"选某一路数字输出"，BCD-to-7-segment decoder是"直接生成显示该数字所需的段码"。
]

#remark[常见考点：有效电平][
  不同芯片可能对应不同类型的数码管，因此段输出可能是高有效，也可能是低有效。
]

做题时一定先看器件说明或图中的反相标记。若输出是低有效，则"某段被选中"表现为该段输出为低电平；若输出是高有效，则相反。记忆芯片时，不必先死背每个控制端名称，但一定要先分清 *输出接七段* 和 *输出有效电平*。

#strategy[考试速记][
  BCD-to-7-segment decoder = 把4位BCD数字直接翻译成七段数码管的段信号，输出看的是 $a$ 到 $g$，不是10条数字线。
]

#summary[这一小节要记住的点][
  + 输入是4位BCD码，输出是七段显示信号 $a$ 到 $g$
  + 它的任务是驱动数码管显示数字，而不是输出10路十进制线
  + 识别芯片时先抓4位输入和7条段输出
  + 做题时要先判断段输出是高有效还是低有效
]

= Encoders

#image("/assets/image-20.png")

#overview[编码器的功能][
  编码器把某一路输入信号转换成对应的二进制代码输出。
]

若把前一节的译码器理解成"代码变成线路"，那么编码器正好反过来，是"线路变成代码"。因此最值得记住的一句话是：*译码器是多到一类的选择表达，编码器是一到多位代码的压缩表达。*

#definition[最基本的结构特征][
  + 有多条输入线，通常表示若干个可能被选中的信号
  + 有较少的输出线，用二进制代码表示输入编号
  + 某一时刻通常默认只有一路输入有效
]

#note[和译码器的区别][
  译码器是"输入一个代码，选出一路输出"；编码器是"输入某一路，输出它的代码"。
]

做题时如果你看到很多输入端、只有几位输出端，而且输出像 $A, B, C, D$ 这样的代码位，就应优先想到编码器，而不是译码器。

== Decimal-to-BCD Encoder

#image("/assets/image-21.png")

#overview[十进制到BCD编码][
  decimal-to-BCD encoder把10条十进制输入线中的某一路，编码成4位BCD输出。
]

因为十进制数字有 $0$ 到 $9$ 共10种，所以输入通常有10路；而BCD表示1位十进制数只需要4位，因此输出是4位代码。这一类器件可以记成：*10路输入压成4位BCD。*

#definition[芯片识别抓手][
  + 输入端有10路，对应十进制 $0$ 到 $9$
  + 输出端只有4位，对应BCD码
  + 核心功能是把"哪一路有效"翻译成"这个数字的4位代码"
]

#image("/assets/image-22.png")

#method[它是怎样工作的][
  当某个十进制输入端有效时，输出端就给出该数字对应的4位BCD码。
]

例如，若表示十进制 $5$ 的那一路输入有效，则输出就是数字 $5$ 的BCD码；若表示十进制 $9$ 的那一路输入有效，则输出就是数字 $9$ 的BCD码。

#remark[使用时的默认前提][
  普通编码器通常默认同一时刻只有一路输入有效；若多路同时有效，输出就可能不再唯一。
]

这也是编码器和前面许多芯片不同的地方：它要求输入状态满足一定约束。做题时如果题目没有特别说明，一般就默认是"单输入有效"的正常工作情形。

#strategy[考试速记][
  decimal-to-BCD encoder = 10路十进制输入，4位BCD输出；看见"多输入、少输出、输出是代码"就想到编码器。
]

#summary[这一节要记住的点][
  + 编码器是把某一路输入转换成对应的二进制代码
  + 它和译码器互为反向思路：前者是线路到代码，后者是代码到线路
  + decimal-to-BCD encoder把10路十进制输入编码成4位BCD输出
  + 识别芯片时先抓"10路输入 + 4位输出"这个结构特征
  + 普通编码器通常默认同一时刻只有一路输入有效
]

= Code Converters

#image("/assets/image-23.png")

#overview[码制转换器的功能][
  code converter用来把一种代码表示转换成另一种代码表示，而不改变它所代表的数值。
]

这一节图中给出的不是十进制到BCD那种"编码"问题，而是 *binary code和Gray code之间的互相转换*。它们表示的数字可以相同，但位模式不同。

#definition[为什么要用Gray code][
  Gray code的特点是：相邻两个代码之间通常只有1位发生变化。
]

这使它在位置检测、旋转编码器等场景中特别有用，因为从一个状态跳到下一个状态时，不容易因为多位同时翻转而产生瞬时误判。

#note[看图时先抓住的规律][
  图左是4位binary到Gray的转换；图右是4位Gray到binary的转换；两边都主要由异或门实现。
]

#method[binary到Gray的转换规律][
  + 最高位直接保留：G3 = B3
  + 其余各位由相邻两位binary异或得到：G2 = B3 xor B2，G1 = B2 xor B1，G0 = B1 xor B0
]

所以可以把binary到Gray记成一句话：*最高位照抄，其余各位看相邻binary异或。*

反过来，从Gray还原binary就不能直接套这个规律了。

#method[Gray到binary的转换规律][
  + 最高位直接保留：B3 = G3
  + 其余各位要逐级往下推：B2 = G3 xor G2，B1 = B2 xor G1，B0 = B1 xor G0
]

因此，Gray到binary不能简单地只看相邻两位Gray直接异或，而是要 *从最高位开始，前面算出的binary位继续参与后面的异或*。

这也是图右最值得注意的地方：后一级异或门有一条反馈链，说明后面的binary位要利用前面已经算出的结果。

#remark[为什么两个方向都保留最高位][
  对4位binary和4位Gray的转换，最高位在两个码制中保持相同，因此最高位都可以直接传递。
]

#strategy[考试速记][
  + binary到Gray：最高位不变，其余各位 = 相邻binary异或
  + Gray到binary：最高位不变，其余各位从高位开始逐级异或推出
]

#summary[这一节要记住的点][
  + code converter的任务是不改变数值，只改变代码表示方式
  + Gray code的优势是相邻代码通常只有1位变化
  + binary到Gray时，最高位照抄，其余各位由相邻binary异或得到
  + Gray到binary时，最高位照抄，其余各位必须从高位开始逐级推出
  + 图中双向转换电路的核心器件都是异或门
]

= Multiplexers (Data Selectors)

#image("/assets/image-24.png")

#overview[多路选择器的功能][
  multiplexer的任务是：从多路数据输入中选出一路，把它送到唯一的输出端。
]

所以它和译码器、编码器不同。译码器是"代码选一路输出"，编码器是"某一路输入变成代码"，而multiplexer是 *多路数据里挑一路送出去*。

#definition[最基本的识别抓手][
  + 有多路数据输入，常写成D0、D1、…
  + 有较少的选择输入，常写成S0、S1、…
  + 只有一个输出，常写成 $Y$
]

若有 $n$ 条选择线，则最多可选择 $2^n$ 路数据输入。因此常见的多路选择器会写成4选1、8选1、16选1等形式。

#method[4选1的核心规律][
  图中的4输入multiplexer用两条选择线S1、S0控制输出；不同选择状态下，输出Y直接等于某一路输入。
]

可以把它记成：

+ S1 S0 = 00时，Y = D0
+ S1 S0 = 01时，Y = D1
+ S1 S0 = 10时，Y = D2
+ S1 S0 = 11时，Y = D3

#note[为什么叫data selector][
  因为它并不自己产生新数据，只是把已有数据中的一路选出来。
]

== Dual Four-Input Data Selector/Multiplexer.

#image("/assets/image-25.png")

#overview[74HC153的功能][
  74HC153内部包含两个彼此独立的4选1multiplexer，它们共用选择线，但各自有独立的使能端和输出端。
]

#definition[芯片识别抓手][
  + 两组4路数据输入
  + 一组公共选择线S0、S1
  + 两个输出端1Y、2Y
  + 两个独立使能端1E、2E，且图中为低有效
]

考试若给出管脚图，只要你看到一组公共选择线配两套输入输出，就应优先想到dual multiplexer，而不是普通单个multiplexer。

#remark[使能端的意义][
  低有效使能表示：只有使能端有效时，该路multiplexer才真正把选中的输入送到输出。
]

因此做题时必须先看使能端状态，再看选择线状态，否则会误判输出。

#strategy[考试速记][
  74HC153 = 两个4选1共用选择线，各自独立输出，各自有低有效使能。
]

== Eight-Input Data Selector/Multiplexer.

#image("/assets/image-26.png")

#overview[74HC151的功能][
  74HC151是一个8选1multiplexer，有8路数据输入、3条选择线和1个主输出。
]

因为 $2^3 = 8$，所以3条选择线S0、S1、S2正好可以从D0到D7中选出一路。图中还给出了Y和its complement，也就是正输出与反相输出。

#definition[芯片识别抓手][
  + 8路数据输入：D0到D7
  + 3条选择线：S0、S1、S2
  + 低有效使能端
  + 一对输出：$Y$ 与 $overline(Y)$
]

#image("/assets/image-27.png")

#connection[扩展成16选1][
  两个74HC151可以级联，组成一个16选1multiplexer。
]

图中左边一片负责D0到D7，右边一片负责D8到D15。低3位选择线S0、S1、S2同时送到两片芯片，最高位选择线S3决定哪一片被使能，因此整个系统就能在16路输入中选出一路。

#note[理解级联的关键][
  低位选择线在每一片内部选"组内哪一路"，高位选择线选"到底启用哪一组"。
]

#strategy[考试速记][
  做大规模multiplexer时：低位选择组内输入，高位选择哪一组芯片工作。
]

== 7-Segment Display Multiplexer

#image("/assets/image-28.png")

#overview[数码管动态扫描的思路][
  这一图说明：可以用multiplexer在不同时间片轮流送出不同的BCD数据，再配合位选信号驱动多个数码管。
]

图中数据选择信号在低、高之间切换。低电平时选出A3 A2 A1 A0，高电平时选出B3 B2 B1 B0。被选中的4位BCD码送入BCD/7-seg译码器，产生段信号；同时下方的位选电路只打开对应的那个数码管。

#method[为什么两位都能显示][
  虽然同一时刻实际上只有一位数码管被真正使能，但切换速度足够快时，人眼会感觉两位都在连续发光。
]

#remark[图中真正复用的是什么][
  被复用的是BCD到7段译码这一整套通路，而不是给每一位都单独放一套完整译码器。
]

#strategy[考试速记][
  7段显示multiplexing = 数据轮流送，数码位轮流开，靠快速扫描实现多位同时显示的视觉效果。
]

== Logic Function Generator // 结合真值表的使用

#overview[为什么multiplexer能当逻辑函数发生器][
  因为选择线本身就能表示输入变量的某些组合，而数据输入端可以事先接成0、1、某个变量或变量反相，所以输出就能按真值表产生目标逻辑函数。
]

#method[最常见的做题思路][
  + 先从题目的真值表或逻辑表达式确定要实现的函数
  + 选若干变量作为选择线
  + 按选择线的各个组合，查看输出应为0、1、某变量或某变量反相
  + 再把这些结果分别接到各个数据输入端
]

例如，用8选1multiplexer实现三变量函数时，通常把三个变量直接作为选择线，这样每个数据输入只需接成0或1；若用4选1multiplexer实现三变量函数，则常把其中两个变量作选择线，剩下那个变量决定各数据端接0、1、 $X$ 或 $overline(X)$。

#note[和真值表的对应关系][
  multiplexer的每个数据输入端，本质上就对应选择线某一种取值下，函数应该输出什么。
]

#strategy[考试速记][
  用multiplexer生成逻辑函数时：选择线负责定位真值表的某一行，数据输入端负责填这一行该输出什么。
]

#summary[这一大节要记住的点][
  + multiplexer的本质是多路输入选一路输出
  + 选择线有 $n$ 位，就能在 $2^n$ 路数据中选一路
  + 74HC153是双4选1，74HC151是8选1
  + 多片multiplexer可以级联扩展成更大规模
  + 动态数码显示本质上是数据与位选的时分复用
  + multiplexer还能按真值表连接成logic function generator
]

= Demultiplexers

#image("/assets/image-29.png")

#overview[demultiplexer的功能][
  demultiplexer的任务是：把一路数据输入送到多路输出中的某一路。
]

如果把前一节的multiplexer理解成"多路选一路送出去"，那么demultiplexer正好反过来，是*一路数据按选择线分送到某一路输出*。

#definition[最基本的识别抓手][
  + 只有一路数据输入
  + 有若干条选择线，常写成S0、S1、…
  + 有多路输出，常写成D0、D1、…
]

若有 $n$ 条选择线，则通常可把输入分送到 $2^n$ 路输出中的一路。因此常见写法是1线到4线、1线到8线、1线到16线等。

#method[1线到4线的核心规律][
  图中的1-line-to-4-line demultiplexer有一路数据输入、两条选择线S1与S0，以及4条输出线D0到D3。
]

可以把它记成：

+ S1 S0 = 00时，输入被送到D0
+ S1 S0 = 01时，输入被送到D1
+ S1 S0 = 10时，输入被送到D2
+ S1 S0 = 11时，输入被送到D3

#note[和multiplexer的关系][
  multiplexer是多入一出，demultiplexer是一入多出。
]

#image("/assets/image-30.png")

#overview[decoder可作为demultiplexer][
  只要给decoder加上数据输入与使能控制，它也可以作为demultiplexer使用。
]

图中给出的就是这种典型做法：选择线S0、S1、S2、S3负责决定输出编号，Data in送入器件后，只会出现在某一条被选中的输出线上。

#definition[为什么能这样用][
  decoder本来就能根据选择线只激活一路输出，因此只要把数据输入接入它的使能通路，就能把"选中哪一路"与"把数据送过去"结合起来。
]

因此，很多题目里会把decoder和demultiplexer联系在一起考。识别时要抓住一点：*decoder负责选路，data input负责决定送过去的是0还是1。*

#remark[图中的考试抓手][
  这张图里最关键的是四条选择线S0到S3、一路Data in，以及16条输出线D0到D15。
]

#strategy[考试速记][
  + demultiplexer：一路输入分到多路输出中的一路
  + 选择线有 $n$ 位，就能把输入送到 $2^n$ 路输出中的一路
  + decoder加上数据输入控制后，也能当demultiplexer用
]

#summary[这一节要记住的点][
  + demultiplexer本质上是一入多出，由选择线决定送到哪一路
  + 1线到4线demultiplexer由2条选择线控制4路输出
  + 未被选中的输出保持无效，只有被选中的那一路接收到输入数据
  + decoder和demultiplexer在"选一路"这件事上本质相通
  + 题目若出现S0到S3、Data in与D0到D15，要优先联想到1线到16线demultiplexer
]

= Parity Generators/Checkers

#overview[奇偶校验器的功能][
  parity generator/checker用于生成校验位，或检查一组数据是否满足既定的奇校验或偶校验要求。
]

前面几节的芯片都在处理数据的选择或转换，parity器件则不同——它不关心数据内容，只统计其中1的个数是奇数还是偶数，用于检测传输错误。

#definition[奇校验与偶校验][
  + 偶校验：让整组数据中1的总个数为偶数
  + 奇校验：让整组数据中1的总个数为奇数
]

因此，校验位本质上只是为了把"1的个数奇偶性"调成我们想要的结果。

== 9-Bit Parity Generator/Checker

#image("/assets/image-31.png")

#overview[74HC280的功能][
  74HC280可以对最多9位输入做奇偶校验判断，也可以用来生成一个校验位。
]

#definition[函数表怎么读][
  + 当输入中1的个数是0、2、4、6、8时，ΣEven为高，ΣOdd为低
  + 当输入中1的个数是1、3、5、7、9时，ΣEven为低，ΣOdd为高
]

#note[生成校验位时怎么理解][
  若已知数据位，便可利用奇偶输出决定应补什么校验位，才能让整组数据满足偶校验或奇校验。
]

例如，若希望最终满足偶校验，而当前数据中1的个数已经是偶数，那么校验位就应取0；若当前是奇数，则校验位就应取1。这样整组数据的1的总数就会被调成偶数。

#image("/assets/image-32.png")

#connection[在传输系统中的作用][
  图中左边用parity generator产生偶校验位，右边用parity checker在接收端重新检查。
]

发送端把数据位D0到D6与校验位一起送出。图中D7就作为even parity bit一起进入传输线。接收端收到这一组数据后，再做一次奇偶性检查；若奇偶关系不对，就说明传输过程中出现了错误。

#remark[它能做什么，不能做什么][
  parity check最擅长的是发现单个位错误，但它不能告诉你到底是哪一位错了。
]

#image("/assets/image-33.png")

#method[时序图怎么看][
  图中S0、S1、S2负责选择当前传输的是D0到D7中的哪一位，其中P表示校验位；最下方的Error信号表示接收端是否检测出错误。
]

前半段波形表示正常传输，此时即使数据和校验位轮流送出，接收端最后仍能判定整组数据满足原本的偶校验要求，所以Error保持不变。后半段波形中有一位被错误接收，导致整组数据的奇偶性被破坏，于是Error变为有效。

#strategy[考试速记][
  + parity generator：负责补出校验位
  + parity checker：负责检查收到的数据是否仍满足奇偶要求
  + odd/even parity只能检错，不能定位错位
]

#summary[这一节要记住的点][
  + parity generator/checker看的是整组数据中1的个数奇偶性
  + 74HC280有A到I共9路输入，以及ΣEven、ΣOdd两个输出
  + ΣEven对应"1的个数为偶数"，ΣOdd对应"1的个数为奇数"
  + 偶校验位的作用是让整组数据中1的总数变成偶数
  + 传输系统里可用它检测错误，但通常不能判断是哪一位出错
]

= Latches

== S-R (SET-RESET) Latch

#overview[锁存器最基本的存储方式][
  latch用于存储1位二进制信息。它最重要的特征是：输入条件一旦满足，输出会立刻改变；当输入回到无效状态后，输出还能继续保持。
]

这也是它和后面flip-flop的关键区别。latch通常是"电平敏感"，而flip-flop通常是"边沿敏感"。

#image("/assets/image-34.png")

#definition[图中给出的两种S-R latch][
  + 左图是高有效输入S-R latch
  + 右图是低有效输入 $overline(S)$、 $overline(R)$ latch
]

做题时不要只背名称，要先看输入端有没有反相小圆点，或信号名上有没有横线。*谁带反相标记，谁就是低有效。*

#image("/assets/image-35.png")

#method[低有效S-R latch的4种状态][
  + SET： $overline(S) = 0$、 $overline(R) = 1$，输出变成 $Q = 1$
  + RESET： $overline(S) = 1$、 $overline(R) = 0$，输出变成 $Q = 0$
  + 保持：两输入都为1，输出保持原状态
  + 非法：两输入都同时为0，回到无效状态后最终结果不确定
]

#note[高有效与低有效不要混淆][
  高有效版本是"1起作用"，低有效版本是"0起作用"。
]

若题目换成高有效S-R latch，则SET、RESET、保持、非法四种情况的"有效电平"会整体翻过来。看门型和小圆点，比死背真值表更稳。

#strategy[考试速记][
  S-R latch = Set负责置1，Reset负责置0，输入撤销后继续保持；两个有效输入同时出现属于非法状态。
]

=== 74HC279A

#overview[74HC279A是四个低有效S-R latch的封装器件][
  这片芯片的考试重点不只是整体功能，还包括"只给管脚编号时，能不能立刻判断它属于哪一个latch的哪一类端子"。
]

#image("/assets/image-36.png")

#definition[先抓整体结构][
  + 它共有4个低有效S-R latch，输出分别是1Q、2Q、3Q、4Q
  + 第1组与第3组各有两个置位输入
  + 8脚是GND，16脚是VCC
]

#method[按管脚编号分组记][
  + 第1组：1脚1R，2脚1S1，3脚1S2，4脚1Q
  + 第2组：5脚2R，6脚2S，7脚2Q
  + 第3组：9脚3Q，10脚3R，11脚3S1，12脚3S2
  + 第4组：13脚4Q，14脚4R，15脚4S
]

#note[记忆顺序][
  先找电源脚8、16，再找4个Q输出脚4、7、9、13，最后把剩余输入按4组归位。
]

#remark[做题时的功能判断][
  一旦看到4个Q输出配多组低有效S、R输入，就应优先想到这是多路S-R latch器件，而不是register或flip-flop。
]

#strategy[给定管脚编号时的快速判断][
  + 1 → 1R（第1组复位）
  + 2、3 → 1S1、1S2（第1组两个置位）
  + 4 → 1Q
  + 5 → 2R，6 → 2S，7 → 2Q
  + 8 → GND，16 → VCC
  + 9 → 3Q，10 → 3R，11、12 → 3S1、3S2
  + 13 → 4Q，14 → 4R，15 → 4S
]

#summary[这一小节要记住的点][
  + 74HC279A = 4个低有效S-R latch
  + 第1组与第3组各有两个置位端
  + 4、7、9、13是4个Q输出
  + 8是GND，16是VCC
]

== Gated S-R Latch

#overview[EN决定当前是否允许改写状态][
  gated S-R latch并没有改变S-R存储的本质，只是在S、R前面加了一道由EN控制的门。
]

#image("/assets/image-37.png")

#method[工作规律][
  + EN无效时，输出保持原状态
  + EN有效时，电路才按普通S-R latch的规则工作
  + 若EN有效且S、R同时取有效值，仍会落入非法状态
]

== Gated D Latch

#overview[把S-R latch改成单输入数据锁存器][
  gated D latch用一个数据输入D取代了分开的S、R，因此不再需要直接面对S-R latch最麻烦的非法输入组合。
]

#image("/assets/image-38.png")

#method[最核心的两句话][
  + EN有效时， $Q$ 跟随 $D$
  + EN无效时， $Q$ 保持上一状态
]

#remark[为什么不会出现非法输入][
  图中一条支路直接取D，另一条支路取反相后的D，所以内部不会同时把置位与复位都激活。
]

#strategy[考试速记][
  D latch = 使能开时透明，使能关时保持。
]

=== 74HC75

#overview[74HC75是四个高有效D latch封装在一片芯片里][
  它最重要的结构特征不是"有4个D"，而是"前两组共用一根控制线，后两组共用另一根控制线"。
]

#image("/assets/image-39.png")

#definition[每个latch的功能关系][
  + 当 $D = 0$ 且EN = 1时，对应输出被RESET
  + 当 $D = 1$ 且EN = 1时，对应输出被SET
  + 当EN = 0时，无论D为何，输出保持原状态
]

#method[按管脚编号分组记][
  + 第1组：1脚是1Q反相输出，2脚是1D，16脚是1Q
  + 第2组：3脚是2D，14脚是2Q反相输出，15脚是2Q
  + 第3组：6脚是3D，10脚是3Q，11脚是3Q反相输出
  + 第4组：7脚是4D，8脚是4Q反相输出，9脚是4Q
  + 共用控制：13脚控制第1、2组，4脚控制第3、4组
]

#note[考试抓手][
  一看到13脚就先想到"前两组共用控制"，一看到4脚就先想到"后两组共用控制"。
]

#strategy[给定管脚编号时的快速判断][
  + 1 → 1Q反相，2 → 1D，16 → 1Q
  + 3 → 2D，14 → 2Q反相，15 → 2Q
  + 13 → 控制第1、2组（EN）
  + 6 → 3D，10 → 3Q，11 → 3Q反相
  + 7 → 4D，8 → 4Q反相，9 → 4Q
  + 4 → 控制第3、4组（EN）
  + 5 → GND，12 → VCC
]

#summary[这一小节要记住的点][
  + 74HC75 = 4个高有效D latch
  + 13脚控制第1、2组
  + 4脚控制第3、4组
  + 每组都有Q与反相输出
]

= Flip-Flops

#overview[flip-flop通常只在时钟边沿更新][
  图中的小三角表示动态输入，也就是时钟边沿触发；没有小圆点表示上升沿触发，带小圆点表示下降沿触发。
]

所以，latch更像"看一个时间窗口"，flip-flop更像"只认边沿瞬间"。做题时先看时钟端符号，再判断它究竟是正边沿还是负边沿。

#image("/assets/image-40.png")

== D Flip-Flop

#overview[边沿到来时把D送到Q][
  D flip-flop最核心的规律非常直接：在有效时钟边沿到来的那一刻，输出Q取输入D的值；边沿过去之后，输出继续保持。
]

#image("/assets/image-42.png")

#definition[正边沿D flip-flop的两种结果][
  + 若边沿到来时 $D = 1$，则输出被SET
  + 若边沿到来时 $D = 0$，则输出被RESET
]

#image("/assets/image-45.png")

#method[为什么它只在边沿动作][
  图中的pulse transition detector会在时钟跳变瞬间产生一个很窄的脉冲，只在这极短时间内打开内部通路。
]

#image("/assets/image-46.png")

#note[考试看符号的顺序][
  先看时钟端有没有小三角，再看三角旁边有没有小圆点。无圆点是上升沿触发，有小圆点是下降沿触发。
]

#image("/assets/image-49.png")

#remark[异步预置与清零要和普通时钟输入分开记][
  图中加入的 $overline(P R E)$ 与 $overline(C L R)$ 说明：某些D flip-flop除了常规的D与CLK以外，还带有异步置位和异步清零端。这两类输入一旦有效，会直接改写输出，而不必等待时钟边沿。
]

#strategy[考试速记][
  D flip-flop = 时钟边沿来时把数据抄进去，平时不跟着输入乱动。
]

=== 74HC74

#overview[74HC74是双正边沿D flip-flop][
  两个flip-flop彼此独立，只共享电源。它们都带有低有效异步PRE和CLR，因此考试很喜欢直接用管脚编号考"这一下到底是同步动作还是异步动作"。
]

#image("/assets/image-50.png")

#definition[先记整体功能][
  + 时钟方式：正边沿触发
  + 异步控制：PRE与CLR都为低有效
  + 每组都有D、CLK、PRE、CLR、Q、反相Q
]

#method[按管脚编号分两组记][
  + 第1组：1脚1CLR，2脚1D，3脚1CLK，4脚1PRE，5脚1Q，6脚1Q反相输出
  + 第2组：8脚2Q反相输出，9脚2Q，10脚2PRE，11脚2CLK，12脚2D，13脚2CLR
  + 电源脚：7脚GND，14脚VCC
]

#note[最容易考错的点][
  1脚、4脚、10脚、13脚都不是普通数据脚，而是低有效异步控制脚。只要它们被拉到有效电平，电路就不必等待时钟边沿。
]

#strategy[考试抓手][
  若题目只给出4脚或1脚，先想到PRE、CLR；若给出3脚或11脚，才想到时钟边沿采样。
]

#strategy[给定管脚编号时的快速判断][
  + 1 → 1CLR，2 → 1D，3 → 1CLK，4 → 1PRE，5 → 1Q，6 → 1Q反相
  + 7 → GND，14 → VCC
  + 8 → 2Q反相，9 → 2Q，10 → 2PRE，11 → 2CLK，12 → 2D，13 → 2CLR
]

#summary[这一小节要记住的点][
  + 74HC74 = 双正边沿D flip-flop
  + PRE、CLR都是低有效异步输入
  + 1到6脚主要对应第1组，8到13脚主要对应第2组
  + 7是GND，14是VCC
]

== J-K Flip-Flop

#overview[J-K flip-flop把"置位/复位"的思想保留下来，同时消除了S-R latch的非法输入组合][
  它最关键的特征是：当 $J = 1$、 $K = 1$ 时，输出不是非法，而是在每个有效时钟边沿翻转一次。
]

#image("/assets/image-43.png")

#definition[4种输入情况][
  + $J = 0$、 $K = 0$：保持
  + $J = 0$、 $K = 1$：RESET
  + $J = 1$、 $K = 0$：SET
  + $J = 1$、 $K = 1$：TOGGLE
]

#image("/assets/image-44.png")

#method[真值表里最值得单独记住的一行][
  $J = 1$、 $K = 1$ 对应的是toggle。这一行最容易被和S-R latch的非法状态混淆，但它恰恰是J-K flip-flop最有用的地方。
]

#image("/assets/image-47.png")

#note[为什么11会翻转][
  图中的内部反馈把当前的Q与反相Q重新送回输入网络，因此在 $J = K = 1$ 时，新的输出会自动变成旧状态的相反值。
]

#image("/assets/image-48.png")

正因为11会翻转，J-K flip-flop特别适合做分频器和计数器。图中的连续脉冲就展示了：只要时钟不断来，它就能不断在两种状态之间切换。

#strategy[考试速记][
  J-K flip-flop = 00保持，01清零，10置1，11翻转。
]

=== 74HC112

#overview[74HC112是双负边沿J-K flip-flop][
  这片器件的记忆重点有三层：先认下降沿时钟，再认低有效PRE和CLR，最后按编号分清第1组和第2组。
]

#image("/assets/image-51.png")

#definition[整体功能][
  + 时钟方式：负边沿触发
  + 异步控制：PRE与CLR低有效
  + 每组都有J、K、CLK、PRE、CLR、Q、反相Q
]

#method[按管脚编号分组记][
  + 第1组：1脚1CLK，2脚1J，3脚1K，4脚1PRE，5脚1Q，6脚1Q反相输出，15脚1CLR
  + 第2组：7脚2Q反相输出，9脚2Q，10脚2PRE，11脚2K，12脚2J，13脚2CLK，14脚2CLR
  + 电源脚：8脚GND，16脚VCC
]

#note[考试抓手][
  1脚和13脚都是带小圆点的时钟脚，说明两组都在下降沿动作；4、10、14、15则是最爱被拿来考的异步控制脚。
]

#strategy[给定管脚编号时的快速判断][
  + 1 → 1CLK，2 → 1J，3 → 1K，4 → 1PRE，5 → 1Q，6 → 1Q反相，15 → 1CLR
  + 8 → GND，16 → VCC
  + 7 → 2Q反相，9 → 2Q，10 → 2PRE，11 → 2K，12 → 2J，13 → 2CLK，14 → 2CLR
]

#summary[这一小节要记住的点][
  + 74HC112 = 双负边沿J-K flip-flop
  + PRE、CLR都是低有效异步输入
  + 8是GND，16是VCC
  + 11与12分别是第2组的K、J，位置很容易考反
]

== Parallel Data Storage

#overview[并行存储就是"同一拍把多位一起装进去"][
  图中4个D flip-flop共用同一时钟与清零端，所以在同一个时钟边沿到来时， $D_0$ 到 $D_3$ 会同时被送到 $Q_0$ 到 $Q_3$。
]

#image("/assets/image-53.png")

#note[为什么叫parallel][
  说的是4位数据通过4条独立通路同时被采样、同时被存储，而不是说只用一条线串行送入。
]

== Frequency Division

#overview[flip-flop天然适合做分频器][
  若把D flip-flop接成 $D = overline(Q)$，或把J-K flip-flop接成 $J = K = 1$，那么每来一个有效时钟边沿，输出就翻转一次。
]

#image("/assets/image-54.png")

#method[最直接的结果][
  + 输出翻转一次要消耗两个时钟边沿，所以单级可实现二分频
  + 两级串接后，第2级再把第1级减半，于是得到四分频
]

#image("/assets/image-55.png")

#strategy[考试速记][
  每多串一级翻转型flip-flop，频率再除以2。
]

== Counting

#overview[把分频链换个角度看，就是二进制计数器][
  图中的两级J-K flip-flop都工作在翻转模式，因此输出 $Q_A$、 $Q_B$ 会依次形成00、01、10、11的二进制序列。
]

#image("/assets/image-56.png")

#method[怎么看波形][
  + $Q_A$ 变化更快，所以是低位
  + $Q_B$ 变化更慢，所以是高位
  + 图中8个时钟脉冲清楚展示了计数序列的重复循环
]

#summary[这一大节要记住的点][
  + latch通常是电平敏感，flip-flop通常是边沿敏感
  + D flip-flop在时钟边沿把D送到Q
  + J-K flip-flop的11状态表示翻转，不是非法
  + 74HC74是双正边沿D flip-flop，74HC112是双负边沿J-K flip-flop
  + flip-flop的常见应用是并行存储、分频与计数
]

= One-Shots

#overview[one-shot又叫单稳态电路][
  它平时只有一个稳定状态；一旦被触发，就暂时跳到另一个状态，输出一个固定宽度的脉冲，随后自动回到原来的稳定状态。
]

flip-flop的输出会一直保持，直到下一个时钟边沿。one-shot则不同——它只在被触发后输出一段固定宽度的脉冲，然后自动复位。

#image("/assets/image-57.png")

#definition[看波形时先抓住两件事][
  + 触发脉冲只负责"启动一次"
  + 输出脉冲宽度 $t_W$ 主要由外部定时元件决定
]

#image("/assets/image-58.png")

#note[两类one-shot的区别][
  + nonretriggerable：输出脉冲尚未结束时，新触发会被忽略
  + retriggerable：若在脉冲期间再次触发，脉冲会被重新计时并拉长
]

#image("/assets/image-59.png")

#method[nonretriggerable的看图方式][
  只要第一个输出脉冲还没结束，后面落在这段时间里的触发都被忽略，所以输出宽度不会被拉长。
]

#image("/assets/image-60.png")

#method[retriggerable的看图方式][
  第二个触发若落在原输出脉冲期间，就会把计时重新开始，因此输出高电平会继续向后延伸。
]

#strategy[考试速记][
  one-shot = 触发一下，只出一个定宽脉冲；能不能在脉冲期间重触发，是区分两类器件的关键。
]

== Nonretriggerable One-Shot

=== 74121

#overview[74121是不允许脉冲期间重触发的单稳态器件][
  图中的考点可以直接分成3类：触发输入、输出端、定时端。
]

#image("/assets/image-61.png")

#definition[按功能分组记管脚][
  + 触发输入：3脚A1、4脚A2、5脚B
  + 输出端：6脚Q、1脚反相Q
  + 定时相关：9脚RINT、10脚CEXT、11脚REXT/CEXT
]

#image("/assets/image-62.png")

#method[图中给出的3种定时方式][
  + 只靠内部电阻时，输出脉冲极窄
  + 接外部CEXT并利用内部电阻时，脉宽随电容改变
  + 同时接外部REXT与CEXT时，脉宽由外部RC共同决定，最常用：
  $ t_W = 0.7 R_"EXT" C_"EXT" $
]

#note[考试抓手][
  看到74121时，先找1、6这对输出，再找9、10、11这组三个定时脚，最后再回头看3、4、5三个触发输入。
]

#strategy[给定管脚编号时的快速判断][
  + 1 → Q反相，6 → Q
  + 3 → A1，4 → A2，5 → B（触发输入）
  + 9 → RINT，10 → CEXT，11 → REXT/CEXT（定时）
  + 2 → VCC，7 → GND，14 → VCC（注意14脚也是VCC）
]

== Retriggerable One-Shot

=== 74LS122

#overview[74LS122允许在脉冲尚未结束时再次触发][
  这就是它和74121最大的区别：新的触发不会被忽略，而会把当前输出脉冲继续向后延长。
]

#image("/assets/image-63.png")

#definition[按功能分组记管脚][
  + 触发输入：1脚A1、2脚A2、3脚B1、4脚B2
  + 清零端：5脚CLR
  + 输出端：8脚Q、6脚反相Q
  + 定时相关：9脚RINT、10脚CEXT、11脚REXT/CEXT
]

脉宽公式与74121相同：

$ t_W = 0.7 R_"EXT" C_"EXT" $

#image("/assets/image-64.png")

#method[图中的级联时序电路][
  三个74LS122首尾串接后，前一级的输出可以作为后一级的触发源，因此会依次产生 $Q_1$、 $Q_2$、 $Q_3$ 三段顺序脉冲。
]

#summary[这一小节要记住的点][
  + 74121是nonretriggerable
  + 74LS122是retriggerable
  + 两类器件都要重点记输出脚与定时脚
  + 74LS122还要特别记住5脚CLR
]

#strategy[给定管脚编号时的快速判断（74LS122）][
  + 1 → A1，2 → A2，3 → B1，4 → B2（触发输入）
  + 5 → CLR（低有效清零）
  + 6 → Q反相，8 → Q
  + 9 → RINT，10 → CEXT，11 → REXT/CEXT（定时）
  + 7 → GND，14 → VCC
]

=== 555 Timer as an One-Shot

#overview[555接成单稳态时，本质上也是one-shot][
  但考试更常见的问法不是"它是不是单稳态"，而是直接给出管脚编号，要求你判断哪些脚负责触发、阈值检测、放电和输出。
]

#image("/assets/image-66.png")

#definition[555最需要背下来的8个管脚功能][
  + 1脚GND
  + 2脚Trigger
  + 3脚Output
  + 4脚Reset
  + 5脚Control voltage
  + 6脚Threshold
  + 7脚Discharge
  + 8脚VCC
]

#image("/assets/image-67.png")

#method[接成one-shot时最关键的分工][
  + 2脚接收负触发脉冲，启动输出脉冲
  + 6脚监视定时电容电压何时达到阈值
  + 7脚在结束后负责把电容放电
  + 3脚给出最终输出脉冲
]

图中的外接方式也很值得直接背下来：4脚通常接高电平保持器件不被复位，5脚常接一个小电容做去耦，R1与C1共同决定脉宽：

$ t_W = 1.1 R_1 C_1 $

#image("/assets/image-68.png")

#remark[图中展示的3步过程][
  + 触发前：输出为低，放电晶体管导通，电容基本被放空
  + 触发后：输出变高，放电晶体管截止，电容经R1充电
  + 到达阈值后：锁存器被复位，输出回低，7脚重新把电容放掉
]

#strategy[考试速记][
  555作one-shot时：2脚触发，6脚判阈值，7脚放电，3脚输出，1脚与8脚是电源脚。
]

#strategy[给定管脚编号时的快速判断][
  + 1 → GND，8 → VCC
  + 2 → Trigger（负触发）
  + 3 → Output
  + 4 → Reset（低有效，通常接高）
  + 5 → Control voltage（通常接去耦电容）
  + 6 → Threshold（监视电容电压）
  + 7 → Discharge（放电通路）
]

#summary[这一大节要记住的点][
  + one-shot平时只有一个稳定状态
  + nonretriggerable会忽略脉冲期间的新触发
  + retriggerable会用新触发延长脉冲
  + 74121与74LS122都要重点记输出脚和定时脚
  + 555必须熟记8个管脚功能
]

= Astable Multivibrator

#overview[astable multivibrator没有稳定静止态，会自行来回翻转][
  它不需要外部周期性触发，而是靠电容反复充放电，使输出持续振荡。
]

one-shot被触发一次只输出一个脉冲，之后回到静止。astable multivibrator则完全不同——它没有稳定状态，会持续自行振荡，不需要任何外部触发。

#image("/assets/image-69.png")

#method[Figure 7-55最该抓住的波形][
  + 输入节点 $V_(i n)$ 在上阈值UTP与下阈值LTP之间来回摆动
  + 输出节点 $V_(o u t)$ 在高低电平之间持续翻转
]

Schmitt trigger的上下阈值保证了电路不会停在中间模糊区，这正是它能稳定振荡的关键。

== 555 Timer as an Astable Multivibrator

#overview[555接成astable模式后，可以连续输出矩形波][
  这类题的重点通常有两处：第一，哪些管脚要怎么连；第二，电容到底沿哪条路径充电、沿哪条路径放电。
]

#image("/assets/image-70.png")

#definition[最关键的连线关系][
  + 2脚与6脚并在一起，作为电容电压检测点
  + 7脚接在 $R_1$ 与 $R_2$ 之间，负责放电通路
  + 4脚接高电平，5脚常接小电容去耦
  + 1脚与8脚分别是GND与VCC
]

#image("/assets/image-71.png")

#method[一个周期内发生的事][
  + 输出为高时，放电晶体管截止，电容通过 $R_1 + R_2$ 充电
  + 电容电压升到上阈值后，输出翻为低，放电晶体管导通
  + 输出为低时，电容通过 $R_2$ 与7脚放电到下阈值
  + 到达下阈值后，又开始下一轮充电
]

#image("/assets/image-72.png")

#note[频率由什么决定][
  振荡频率与各时间段的计算公式：

  $ t_H = 0.7 (R_1 + R_2) C_1 $

  $ t_L = 0.7 R_2 C_1 $

  $ f = frac(1.44, (R_1 + 2 R_2) C_1) $

  其中 $t_H$ 是高电平持续时间，$t_L$ 是低电平持续时间。
]

#remark[为什么占空比常常大于50%][
  因为充电路径经过 $R_1 + R_2$，而放电路径只经过 $R_2$，所以高电平持续时间通常比低电平更长。
]

#image("/assets/image-73.png")

#connection[Figure 7-59的改进思路][
  加入二极管 $D_1$ 后，充电与放电路径被进一步分开，于是可把占空比调到低于50%。图中强调的正是"让 $R_1 lt R_2$"。
]

#summary[这一大节要记住的点][
  + astable multivibrator会自行连续振荡
  + 555作astable时，2脚与6脚并接，7脚负责放电
  + 电容在上下阈值之间反复充放电
  + 频率主要由 $C_1$ 与 $R_1 + 2 R_2$ 决定
  + 加二极管可把占空比调到低于50%
]

#todo[补全][
  补全下面的几章。要求：面向考试，具名芯片要背管脚，知道优先级和行为。讲解性文字结合图片（文字穿插在图片间）。
]

= Asynchronous Counter

== Binary Asynchronous Counter

#image("/assets/image-75.png")

#image("/assets/image-76.png")

#image("/assets/image-77.png")

=== 74HC93

#image("/assets/image-80.png")

#image("/assets/image-81.png")

== Decade Asynchronous Counter

#image("/assets/image-78.png")

== Modulus Asynchronous Counter

#image("/assets/image-79.png")

= Synchronous Counter

== Binary Synchronous Counter

#image("/assets/image-82.png")

#image("/assets/image-83.png")

#image("/assets/image-84.png")

#image("/assets/image-85.png")

#image("/assets/image-86.png")

== Synchronous Decade Counter

#image("/assets/image-87.png")

=== 74HC163

#image("/assets/image-88.png")

#image("/assets/image-89.png")

== Up/Down Synchronous Counter

#image("/assets/image-90.png")

=== 74HC190

#image("/assets/image-91.png")

#image("/assets/image-92.png")

== Synchronous Gray Code Counter

#image("/assets/image-93.png")

= Cascaded Counters

#image("/assets/image-94.png")

#image("/assets/image-95.png")

#image("/assets/image-96.png")

#image("/assets/image-97.png")

= Counters and Decoders

#image("/assets/image-98.png")

#image("/assets/image-99.png")

#image("/assets/image-100.png")

#image("/assets/image-101.png")

= Counter Applications

#image("/assets/image-102.png")

#image("/assets/image-103.png")

#image("/assets/image-104.png")

#image("/assets/image-105.png")

#image("/assets/image-106.png")
