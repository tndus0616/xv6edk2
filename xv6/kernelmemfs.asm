
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 80 19 80       	mov    $0x80198080,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 67 33 10 80       	mov    $0x80103367,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 40 a0 10 80       	push   $0x8010a040
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 85 46 00 00       	call   80104703 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 47 a0 10 80       	push   $0x8010a047
801000c2:	50                   	push   %eax
801000c3:	e8 de 44 00 00       	call   801045a6 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave
801000f2:	c3                   	ret

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 1f 46 00 00       	call   80104725 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 4e 46 00 00       	call   80104793 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 8b 44 00 00       	call   801045e2 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 cd 45 00 00       	call   80104793 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 0a 44 00 00       	call   801045e2 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 4e a0 10 80       	push   $0x8010a04e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave
80100200:	c3                   	ret

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 1c 9d 00 00       	call   80109f4e <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave
80100239:	c3                   	ret

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 45 44 00 00       	call   80104694 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 5f a0 10 80       	push   $0x8010a05f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 d1 9c 00 00       	call   80109f4e <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave
80100282:	c3                   	ret

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 fc 43 00 00       	call   80104694 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 66 a0 10 80       	push   $0x8010a066
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 8b 43 00 00       	call   80104646 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 5a 44 00 00       	call   80104725 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 58 44 00 00       	call   80104793 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave
80100340:	c3                   	ret

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8b 03 00 00       	call   8010076e <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave
801003f3:	c3                   	ret

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 10 43 00 00       	call   80104725 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 6d a0 10 80       	push   $0x8010a06d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 1f 03 00 00       	call   8010076e <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 76 a0 10 80 	movl   $0x8010a076,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 43 02 00 00       	call   8010076e <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 26 02 00 00       	call   8010076e <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 17 02 00 00       	call   8010076e <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 09 02 00 00       	call   8010076e <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 f0 41 00 00       	call   80104793 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave
801005a8:	c3                   	ret

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 39 25 00 00       	call   80102afc <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 7d a0 10 80       	push   $0x8010a07d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 91 a0 10 80       	push   $0x8010a091
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 e2 41 00 00       	call   801047e5 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 93 a0 10 80       	push   $0x8010a093
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	90                   	nop
8010063c:	eb fd                	jmp    8010063b <panic+0x92>

8010063e <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063e:	55                   	push   %ebp
8010063f:	89 e5                	mov    %esp,%ebp
80100641:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100644:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100648:	75 64                	jne    801006ae <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010064a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100650:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100655:	89 c8                	mov    %ecx,%eax
80100657:	f7 ea                	imul   %edx
80100659:	89 d0                	mov    %edx,%eax
8010065b:	c1 f8 04             	sar    $0x4,%eax
8010065e:	89 ca                	mov    %ecx,%edx
80100660:	c1 fa 1f             	sar    $0x1f,%edx
80100663:	29 d0                	sub    %edx,%eax
80100665:	6b d0 35             	imul   $0x35,%eax,%edx
80100668:	89 c8                	mov    %ecx,%eax
8010066a:	29 d0                	sub    %edx,%eax
8010066c:	ba 35 00 00 00       	mov    $0x35,%edx
80100671:	29 c2                	sub    %eax,%edx
80100673:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100678:	01 d0                	add    %edx,%eax
8010067a:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100684:	3d 23 04 00 00       	cmp    $0x423,%eax
80100689:	0f 8e dc 00 00 00    	jle    8010076b <graphic_putc+0x12d>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100694:	83 e8 35             	sub    $0x35,%eax
80100697:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069c:	83 ec 0c             	sub    $0xc,%esp
8010069f:	6a 1e                	push   $0x1e
801006a1:	e8 15 78 00 00       	call   80107ebb <graphic_scroll_up>
801006a6:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a9:	e9 bd 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
  }else if(c == BACKSPACE){
801006ae:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b5:	75 1f                	jne    801006d6 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bc:	85 c0                	test   %eax,%eax
801006be:	0f 8e a7 00 00 00    	jle    8010076b <graphic_putc+0x12d>
801006c4:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c9:	83 e8 01             	sub    $0x1,%eax
801006cc:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d1:	e9 95 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006db:	3d 23 04 00 00       	cmp    $0x423,%eax
801006e0:	7e 1a                	jle    801006fc <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e7:	83 e8 35             	sub    $0x35,%eax
801006ea:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ef:	83 ec 0c             	sub    $0xc,%esp
801006f2:	6a 1e                	push   $0x1e
801006f4:	e8 c2 77 00 00       	call   80107ebb <graphic_scroll_up>
801006f9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fc:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100702:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	f7 ea                	imul   %edx
8010070b:	89 d0                	mov    %edx,%eax
8010070d:	c1 f8 04             	sar    $0x4,%eax
80100710:	89 ca                	mov    %ecx,%edx
80100712:	c1 fa 1f             	sar    $0x1f,%edx
80100715:	29 d0                	sub    %edx,%eax
80100717:	6b d0 35             	imul   $0x35,%eax,%edx
8010071a:	89 c8                	mov    %ecx,%eax
8010071c:	29 d0                	sub    %edx,%eax
8010071e:	89 c2                	mov    %eax,%edx
80100720:	c1 e2 04             	shl    $0x4,%edx
80100723:	29 c2                	sub    %eax,%edx
80100725:	8d 42 02             	lea    0x2(%edx),%eax
80100728:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072b:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100731:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100736:	89 c8                	mov    %ecx,%eax
80100738:	f7 ea                	imul   %edx
8010073a:	c1 fa 04             	sar    $0x4,%edx
8010073d:	89 c8                	mov    %ecx,%eax
8010073f:	c1 f8 1f             	sar    $0x1f,%eax
80100742:	29 c2                	sub    %eax,%edx
80100744:	6b c2 1e             	imul   $0x1e,%edx,%eax
80100747:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074a:	83 ec 04             	sub    $0x4,%esp
8010074d:	ff 75 08             	push   0x8(%ebp)
80100750:	ff 75 f0             	push   -0x10(%ebp)
80100753:	ff 75 f4             	push   -0xc(%ebp)
80100756:	e8 cd 77 00 00       	call   80107f28 <font_render>
8010075b:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100763:	83 c0 01             	add    $0x1,%eax
80100766:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076b:	90                   	nop
8010076c:	c9                   	leave
8010076d:	c3                   	ret

8010076e <consputc>:


void
consputc(int c)
{
8010076e:	55                   	push   %ebp
8010076f:	89 e5                	mov    %esp,%ebp
80100771:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100774:	a1 ec 19 19 80       	mov    0x801919ec,%eax
80100779:	85 c0                	test   %eax,%eax
8010077b:	74 08                	je     80100785 <consputc+0x17>
    cli();
8010077d:	e8 bf fb ff ff       	call   80100341 <cli>
    for(;;)
80100782:	90                   	nop
80100783:	eb fd                	jmp    80100782 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 9c 5b 00 00       	call   80106334 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 8f 5b 00 00       	call   80106334 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 82 5b 00 00       	call   80106334 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 72 5b 00 00       	call   80106334 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6e fe ff ff       	call   8010063e <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave
801007d5:	c3                   	ret

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 35 3f 00 00       	call   80104725 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 58 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 18 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1c ff ff ff       	call   8010076e <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e1 00 00 00    	je     80100949 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c6 00 00 00       	jmp    80100949 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b6 00 00 00    	je     8010094c <consoleintr+0x176>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 be fe ff ff       	call   8010076e <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 94 00 00 00       	jmp    8010094c <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 8d 00 00 00    	je     8010094f <consoleintr+0x179>
801008c2:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008c8:	a1 e0 19 19 80       	mov    0x801919e0,%eax
801008cd:	29 c2                	sub    %eax,%edx
801008cf:	83 fa 7f             	cmp    $0x7f,%edx
801008d2:	77 7b                	ja     8010094f <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 62 fe ff ff       	call   8010076e <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100921:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100926:	83 e8 80             	sub    $0xffffff80,%eax
80100929:	39 c2                	cmp    %eax,%edx
8010092b:	75 22                	jne    8010094f <consoleintr+0x179>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 7c 3a 00 00       	call   801043c0 <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	eb 06                	jmp    8010094f <consoleintr+0x179>
      break;
80100949:	90                   	nop
8010094a:	eb 04                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094c:	90                   	nop
8010094d:	eb 01                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094f:	90                   	nop
  while((c = getc()) >= 0){
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	ff d0                	call   *%eax
80100955:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010095c:	0f 89 96 fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
80100962:	83 ec 0c             	sub    $0xc,%esp
80100965:	68 00 1a 19 80       	push   $0x80191a00
8010096a:	e8 24 3e 00 00       	call   80104793 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 fe 3a 00 00       	call   8010447b <procdump>
  }
}
8010097d:	90                   	nop
8010097e:	c9                   	leave
8010097f:	c3                   	ret

80100980 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100980:	55                   	push   %ebp
80100981:	89 e5                	mov    %esp,%ebp
80100983:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100986:	83 ec 0c             	sub    $0xc,%esp
80100989:	ff 75 08             	push   0x8(%ebp)
8010098c:	e8 74 11 00 00       	call   80101b05 <iunlock>
80100991:	83 c4 10             	add    $0x10,%esp
  target = n;
80100994:	8b 45 10             	mov    0x10(%ebp),%eax
80100997:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
8010099a:	83 ec 0c             	sub    $0xc,%esp
8010099d:	68 00 1a 19 80       	push   $0x80191a00
801009a2:	e8 7e 3d 00 00       	call   80104725 <acquire>
801009a7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009aa:	e9 ab 00 00 00       	jmp    80100a5a <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009af:	e8 7c 30 00 00       	call   80103a30 <myproc>
801009b4:	8b 40 24             	mov    0x24(%eax),%eax
801009b7:	85 c0                	test   %eax,%eax
801009b9:	74 28                	je     801009e3 <consoleread+0x63>
        release(&cons.lock);
801009bb:	83 ec 0c             	sub    $0xc,%esp
801009be:	68 00 1a 19 80       	push   $0x80191a00
801009c3:	e8 cb 3d 00 00       	call   80104793 <release>
801009c8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	ff 75 08             	push   0x8(%ebp)
801009d1:	e8 1c 10 00 00       	call   801019f2 <ilock>
801009d6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009de:	e9 ab 00 00 00       	jmp    80100a8e <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
801009e3:	83 ec 08             	sub    $0x8,%esp
801009e6:	68 00 1a 19 80       	push   $0x80191a00
801009eb:	68 e0 19 19 80       	push   $0x801919e0
801009f0:	e8 e4 38 00 00       	call   801042d9 <sleep>
801009f5:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f8:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009fe:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100a03:	39 c2                	cmp    %eax,%edx
80100a05:	74 a8                	je     801009af <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a07:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a0c:	8d 50 01             	lea    0x1(%eax),%edx
80100a0f:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a15:	83 e0 7f             	and    $0x7f,%eax
80100a18:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a1f:	0f be c0             	movsbl %al,%eax
80100a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a25:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a29:	75 17                	jne    80100a42 <consoleread+0xc2>
      if(n < target){
80100a2b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a2e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a31:	73 2f                	jae    80100a62 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a33:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a38:	83 e8 01             	sub    $0x1,%eax
80100a3b:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a40:	eb 20                	jmp    80100a62 <consoleread+0xe2>
    }
    *dst++ = c;
80100a42:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a45:	8d 50 01             	lea    0x1(%eax),%edx
80100a48:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a4e:	88 10                	mov    %dl,(%eax)
    --n;
80100a50:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a54:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a58:	74 0b                	je     80100a65 <consoleread+0xe5>
  while(n > 0){
80100a5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a5e:	7f 98                	jg     801009f8 <consoleread+0x78>
80100a60:	eb 04                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a62:	90                   	nop
80100a63:	eb 01                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a65:	90                   	nop
  }
  release(&cons.lock);
80100a66:	83 ec 0c             	sub    $0xc,%esp
80100a69:	68 00 1a 19 80       	push   $0x80191a00
80100a6e:	e8 20 3d 00 00       	call   80104793 <release>
80100a73:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	push   0x8(%ebp)
80100a7c:	e8 71 0f 00 00       	call   801019f2 <ilock>
80100a81:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a84:	8b 45 10             	mov    0x10(%ebp),%eax
80100a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a8a:	29 c2                	sub    %eax,%edx
80100a8c:	89 d0                	mov    %edx,%eax
}
80100a8e:	c9                   	leave
80100a8f:	c3                   	ret

80100a90 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a90:	55                   	push   %ebp
80100a91:	89 e5                	mov    %esp,%ebp
80100a93:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a96:	83 ec 0c             	sub    $0xc,%esp
80100a99:	ff 75 08             	push   0x8(%ebp)
80100a9c:	e8 64 10 00 00       	call   80101b05 <iunlock>
80100aa1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aa4:	83 ec 0c             	sub    $0xc,%esp
80100aa7:	68 00 1a 19 80       	push   $0x80191a00
80100aac:	e8 74 3c 00 00       	call   80104725 <acquire>
80100ab1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ab4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100abb:	eb 21                	jmp    80100ade <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ac3:	01 d0                	add    %edx,%eax
80100ac5:	0f b6 00             	movzbl (%eax),%eax
80100ac8:	0f be c0             	movsbl %al,%eax
80100acb:	0f b6 c0             	movzbl %al,%eax
80100ace:	83 ec 0c             	sub    $0xc,%esp
80100ad1:	50                   	push   %eax
80100ad2:	e8 97 fc ff ff       	call   8010076e <consputc>
80100ad7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ada:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ae1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ae4:	7c d7                	jl     80100abd <consolewrite+0x2d>
  release(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 00 1a 19 80       	push   $0x80191a00
80100aee:	e8 a0 3c 00 00       	call   80104793 <release>
80100af3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	ff 75 08             	push   0x8(%ebp)
80100afc:	e8 f1 0e 00 00       	call   801019f2 <ilock>
80100b01:	83 c4 10             	add    $0x10,%esp

  return n;
80100b04:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b07:	c9                   	leave
80100b08:	c3                   	ret

80100b09 <consoleinit>:

void
consoleinit(void)
{
80100b09:	55                   	push   %ebp
80100b0a:	89 e5                	mov    %esp,%ebp
80100b0c:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b0f:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b16:	00 00 00 
  initlock(&cons.lock, "console");
80100b19:	83 ec 08             	sub    $0x8,%esp
80100b1c:	68 97 a0 10 80       	push   $0x8010a097
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 d8 3b 00 00       	call   80104703 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 9f a0 10 80 	movl   $0x8010a09f,-0xc(%ebp)
80100b49:	eb 19                	jmp    80100b64 <consoleinit+0x5b>
    graphic_putc(*p);
80100b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b4e:	0f b6 00             	movzbl (%eax),%eax
80100b51:	0f be c0             	movsbl %al,%eax
80100b54:	83 ec 0c             	sub    $0xc,%esp
80100b57:	50                   	push   %eax
80100b58:	e8 e1 fa ff ff       	call   8010063e <graphic_putc>
80100b5d:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b67:	0f b6 00             	movzbl (%eax),%eax
80100b6a:	84 c0                	test   %al,%al
80100b6c:	75 dd                	jne    80100b4b <consoleinit+0x42>
  
  cons.locking = 1;
80100b6e:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b75:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b78:	83 ec 08             	sub    $0x8,%esp
80100b7b:	6a 00                	push   $0x0
80100b7d:	6a 01                	push   $0x1
80100b7f:	e8 b2 1a 00 00       	call   80102636 <ioapicenable>
80100b84:	83 c4 10             	add    $0x10,%esp
}
80100b87:	90                   	nop
80100b88:	c9                   	leave
80100b89:	c3                   	ret

80100b8a <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b8a:	55                   	push   %ebp
80100b8b:	89 e5                	mov    %esp,%ebp
80100b8d:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b93:	e8 98 2e 00 00       	call   80103a30 <myproc>
80100b98:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b9b:	e8 9e 24 00 00       	call   8010303e <begin_op>

  if((ip = namei(path)) == 0){
80100ba0:	83 ec 0c             	sub    $0xc,%esp
80100ba3:	ff 75 08             	push   0x8(%ebp)
80100ba6:	e8 7a 19 00 00       	call   80102525 <namei>
80100bab:	83 c4 10             	add    $0x10,%esp
80100bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bb1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bb5:	75 1f                	jne    80100bd6 <exec+0x4c>
    end_op();
80100bb7:	e8 0e 25 00 00       	call   801030ca <end_op>
    cprintf("exec: fail\n");
80100bbc:	83 ec 0c             	sub    $0xc,%esp
80100bbf:	68 b5 a0 10 80       	push   $0x8010a0b5
80100bc4:	e8 2b f8 ff ff       	call   801003f4 <cprintf>
80100bc9:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd1:	e9 f1 03 00 00       	jmp    80100fc7 <exec+0x43d>
  }
  ilock(ip);
80100bd6:	83 ec 0c             	sub    $0xc,%esp
80100bd9:	ff 75 d8             	push   -0x28(%ebp)
80100bdc:	e8 11 0e 00 00       	call   801019f2 <ilock>
80100be1:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100beb:	6a 34                	push   $0x34
80100bed:	6a 00                	push   $0x0
80100bef:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100bf5:	50                   	push   %eax
80100bf6:	ff 75 d8             	push   -0x28(%ebp)
80100bf9:	e8 e0 12 00 00       	call   80101ede <readi>
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	83 f8 34             	cmp    $0x34,%eax
80100c04:	0f 85 66 03 00 00    	jne    80100f70 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c0a:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c10:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c15:	0f 85 58 03 00 00    	jne    80100f73 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c1b:	e8 10 67 00 00       	call   80107330 <setupkvm>
80100c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c27:	0f 84 49 03 00 00    	je     80100f76 <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3b:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c41:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c44:	e9 de 00 00 00       	jmp    80100d27 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c4c:	6a 20                	push   $0x20
80100c4e:	50                   	push   %eax
80100c4f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c55:	50                   	push   %eax
80100c56:	ff 75 d8             	push   -0x28(%ebp)
80100c59:	e8 80 12 00 00       	call   80101ede <readi>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 f8 20             	cmp    $0x20,%eax
80100c64:	0f 85 0f 03 00 00    	jne    80100f79 <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c6a:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c70:	83 f8 01             	cmp    $0x1,%eax
80100c73:	0f 85 a0 00 00 00    	jne    80100d19 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c79:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c7f:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c85:	39 c2                	cmp    %eax,%edx
80100c87:	0f 82 ef 02 00 00    	jb     80100f7c <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c8d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c93:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c99:	01 c2                	add    %eax,%edx
80100c9b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ca1:	39 c2                	cmp    %eax,%edx
80100ca3:	0f 82 d6 02 00 00    	jb     80100f7f <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ca9:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100caf:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cb5:	01 d0                	add    %edx,%eax
80100cb7:	83 ec 04             	sub    $0x4,%esp
80100cba:	50                   	push   %eax
80100cbb:	ff 75 e0             	push   -0x20(%ebp)
80100cbe:	ff 75 d4             	push   -0x2c(%ebp)
80100cc1:	e8 64 6a 00 00       	call   8010772a <allocuvm>
80100cc6:	83 c4 10             	add    $0x10,%esp
80100cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd0:	0f 84 ac 02 00 00    	je     80100f82 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100cd6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cdc:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ce1:	85 c0                	test   %eax,%eax
80100ce3:	0f 85 9c 02 00 00    	jne    80100f85 <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ce9:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cef:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cf5:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	52                   	push   %edx
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	push   -0x28(%ebp)
80100d03:	51                   	push   %ecx
80100d04:	ff 75 d4             	push   -0x2c(%ebp)
80100d07:	e8 51 69 00 00       	call   8010765d <loaduvm>
80100d0c:	83 c4 20             	add    $0x20,%esp
80100d0f:	85 c0                	test   %eax,%eax
80100d11:	0f 88 71 02 00 00    	js     80100f88 <exec+0x3fe>
80100d17:	eb 01                	jmp    80100d1a <exec+0x190>
      continue;
80100d19:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d1a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d21:	83 c0 20             	add    $0x20,%eax
80100d24:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d27:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d2e:	0f b7 c0             	movzwl %ax,%eax
80100d31:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d34:	0f 8c 0f ff ff ff    	jl     80100c49 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d3a:	83 ec 0c             	sub    $0xc,%esp
80100d3d:	ff 75 d8             	push   -0x28(%ebp)
80100d40:	e8 de 0e 00 00       	call   80101c23 <iunlockput>
80100d45:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d48:	e8 7d 23 00 00       	call   801030ca <end_op>
  ip = 0;
80100d4d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d57:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d67:	05 00 20 00 00       	add    $0x2000,%eax
80100d6c:	83 ec 04             	sub    $0x4,%esp
80100d6f:	50                   	push   %eax
80100d70:	ff 75 e0             	push   -0x20(%ebp)
80100d73:	ff 75 d4             	push   -0x2c(%ebp)
80100d76:	e8 af 69 00 00       	call   8010772a <allocuvm>
80100d7b:	83 c4 10             	add    $0x10,%esp
80100d7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d85:	0f 84 00 02 00 00    	je     80100f8b <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d93:	83 ec 08             	sub    $0x8,%esp
80100d96:	50                   	push   %eax
80100d97:	ff 75 d4             	push   -0x2c(%ebp)
80100d9a:	e8 ed 6b 00 00       	call   8010798c <clearpteu>
80100d9f:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100daf:	e9 96 00 00 00       	jmp    80100e4a <exec+0x2c0>
    if(argc >= MAXARG)
80100db4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100db8:	0f 87 d0 01 00 00    	ja     80100f8e <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcb:	01 d0                	add    %edx,%eax
80100dcd:	8b 00                	mov    (%eax),%eax
80100dcf:	83 ec 0c             	sub    $0xc,%esp
80100dd2:	50                   	push   %eax
80100dd3:	e8 11 3e 00 00       	call   80104be9 <strlen>
80100dd8:	83 c4 10             	add    $0x10,%esp
80100ddb:	89 c2                	mov    %eax,%edx
80100ddd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de0:	29 d0                	sub    %edx,%eax
80100de2:	83 e8 01             	sub    $0x1,%eax
80100de5:	83 e0 fc             	and    $0xfffffffc,%eax
80100de8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 d0                	add    %edx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	83 ec 0c             	sub    $0xc,%esp
80100dff:	50                   	push   %eax
80100e00:	e8 e4 3d 00 00       	call   80104be9 <strlen>
80100e05:	83 c4 10             	add    $0x10,%esp
80100e08:	83 c0 01             	add    $0x1,%eax
80100e0b:	89 c1                	mov    %eax,%ecx
80100e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e1a:	01 d0                	add    %edx,%eax
80100e1c:	8b 00                	mov    (%eax),%eax
80100e1e:	51                   	push   %ecx
80100e1f:	50                   	push   %eax
80100e20:	ff 75 dc             	push   -0x24(%ebp)
80100e23:	ff 75 d4             	push   -0x2c(%ebp)
80100e26:	e8 00 6d 00 00       	call   80107b2b <copyout>
80100e2b:	83 c4 10             	add    $0x10,%esp
80100e2e:	85 c0                	test   %eax,%eax
80100e30:	0f 88 5b 01 00 00    	js     80100f91 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e39:	8d 50 03             	lea    0x3(%eax),%edx
80100e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e3f:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e46:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e54:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e57:	01 d0                	add    %edx,%eax
80100e59:	8b 00                	mov    (%eax),%eax
80100e5b:	85 c0                	test   %eax,%eax
80100e5d:	0f 85 51 ff ff ff    	jne    80100db4 <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e66:	83 c0 03             	add    $0x3,%eax
80100e69:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e70:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e74:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e7b:	ff ff ff 
  ustack[1] = argc;
80100e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e81:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8a:	83 c0 01             	add    $0x1,%eax
80100e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e94:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e97:	29 d0                	sub    %edx,%eax
80100e99:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea2:	83 c0 04             	add    $0x4,%eax
80100ea5:	c1 e0 02             	shl    $0x2,%eax
80100ea8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eae:	83 c0 04             	add    $0x4,%eax
80100eb1:	c1 e0 02             	shl    $0x2,%eax
80100eb4:	50                   	push   %eax
80100eb5:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ebb:	50                   	push   %eax
80100ebc:	ff 75 dc             	push   -0x24(%ebp)
80100ebf:	ff 75 d4             	push   -0x2c(%ebp)
80100ec2:	e8 64 6c 00 00       	call   80107b2b <copyout>
80100ec7:	83 c4 10             	add    $0x10,%esp
80100eca:	85 c0                	test   %eax,%eax
80100ecc:	0f 88 c2 00 00 00    	js     80100f94 <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ede:	eb 17                	jmp    80100ef7 <exec+0x36d>
    if(*s == '/')
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	0f b6 00             	movzbl (%eax),%eax
80100ee6:	3c 2f                	cmp    $0x2f,%al
80100ee8:	75 09                	jne    80100ef3 <exec+0x369>
      last = s+1;
80100eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eed:	83 c0 01             	add    $0x1,%eax
80100ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ef3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efa:	0f b6 00             	movzbl (%eax),%eax
80100efd:	84 c0                	test   %al,%al
80100eff:	75 df                	jne    80100ee0 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f04:	83 c0 6c             	add    $0x6c,%eax
80100f07:	83 ec 04             	sub    $0x4,%esp
80100f0a:	6a 10                	push   $0x10
80100f0c:	ff 75 f0             	push   -0x10(%ebp)
80100f0f:	50                   	push   %eax
80100f10:	e8 89 3c 00 00       	call   80104b9e <safestrcpy>
80100f15:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1b:	8b 40 04             	mov    0x4(%eax),%eax
80100f1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f27:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f30:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f35:	8b 40 18             	mov    0x18(%eax),%eax
80100f38:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f3e:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f41:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f44:	8b 40 18             	mov    0x18(%eax),%eax
80100f47:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f4a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f4d:	83 ec 0c             	sub    $0xc,%esp
80100f50:	ff 75 d0             	push   -0x30(%ebp)
80100f53:	e8 f6 64 00 00       	call   8010744e <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 8d 69 00 00       	call   801078f3 <freevm>
80100f66:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f69:	b8 00 00 00 00       	mov    $0x0,%eax
80100f6e:	eb 57                	jmp    80100fc7 <exec+0x43d>
    goto bad;
80100f70:	90                   	nop
80100f71:	eb 22                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f73:	90                   	nop
80100f74:	eb 1f                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f76:	90                   	nop
80100f77:	eb 1c                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 19                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 16                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 13                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 10                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 0d                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 0a                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f8b:	90                   	nop
80100f8c:	eb 07                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f8e:	90                   	nop
80100f8f:	eb 04                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f91:	90                   	nop
80100f92:	eb 01                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f94:	90                   	nop

 bad:
  if(pgdir)
80100f95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f99:	74 0e                	je     80100fa9 <exec+0x41f>
    freevm(pgdir);
80100f9b:	83 ec 0c             	sub    $0xc,%esp
80100f9e:	ff 75 d4             	push   -0x2c(%ebp)
80100fa1:	e8 4d 69 00 00       	call   801078f3 <freevm>
80100fa6:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fad:	74 13                	je     80100fc2 <exec+0x438>
    iunlockput(ip);
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	ff 75 d8             	push   -0x28(%ebp)
80100fb5:	e8 69 0c 00 00       	call   80101c23 <iunlockput>
80100fba:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fbd:	e8 08 21 00 00       	call   801030ca <end_op>
  }
  return -1;
80100fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc7:	c9                   	leave
80100fc8:	c3                   	ret

80100fc9 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc9:	55                   	push   %ebp
80100fca:	89 e5                	mov    %esp,%ebp
80100fcc:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fcf:	83 ec 08             	sub    $0x8,%esp
80100fd2:	68 c1 a0 10 80       	push   $0x8010a0c1
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 22 37 00 00       	call   80104703 <initlock>
80100fe1:	83 c4 10             	add    $0x10,%esp
}
80100fe4:	90                   	nop
80100fe5:	c9                   	leave
80100fe6:	c3                   	ret

80100fe7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fe7:	55                   	push   %ebp
80100fe8:	89 e5                	mov    %esp,%ebp
80100fea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fed:	83 ec 0c             	sub    $0xc,%esp
80100ff0:	68 a0 1a 19 80       	push   $0x80191aa0
80100ff5:	e8 2b 37 00 00       	call   80104725 <acquire>
80100ffa:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ffd:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80101004:	eb 2d                	jmp    80101033 <filealloc+0x4c>
    if(f->ref == 0){
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	8b 40 04             	mov    0x4(%eax),%eax
8010100c:	85 c0                	test   %eax,%eax
8010100e:	75 1f                	jne    8010102f <filealloc+0x48>
      f->ref = 1;
80101010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101013:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 a0 1a 19 80       	push   $0x80191aa0
80101022:	e8 6c 37 00 00       	call   80104793 <release>
80101027:	83 c4 10             	add    $0x10,%esp
      return f;
8010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102d:	eb 23                	jmp    80101052 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101033:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101038:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103b:	72 c9                	jb     80101006 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 1a 19 80       	push   $0x80191aa0
80101045:	e8 49 37 00 00       	call   80104793 <release>
8010104a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010104d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101052:	c9                   	leave
80101053:	c3                   	ret

80101054 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101054:	55                   	push   %ebp
80101055:	89 e5                	mov    %esp,%ebp
80101057:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 a0 1a 19 80       	push   $0x80191aa0
80101062:	e8 be 36 00 00       	call   80104725 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 c8 a0 10 80       	push   $0x8010a0c8
8010107c:	e8 28 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	8d 50 01             	lea    0x1(%eax),%edx
8010108a:	8b 45 08             	mov    0x8(%ebp),%eax
8010108d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 a0 1a 19 80       	push   $0x80191aa0
80101098:	e8 f6 36 00 00       	call   80104793 <release>
8010109d:	83 c4 10             	add    $0x10,%esp
  return f;
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a3:	c9                   	leave
801010a4:	c3                   	ret

801010a5 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a5:	55                   	push   %ebp
801010a6:	89 e5                	mov    %esp,%ebp
801010a8:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ab:	83 ec 0c             	sub    $0xc,%esp
801010ae:	68 a0 1a 19 80       	push   $0x80191aa0
801010b3:	e8 6d 36 00 00       	call   80104725 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 d0 a0 10 80       	push   $0x8010a0d0
801010cd:	e8 d7 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 04             	mov    0x4(%eax),%eax
801010d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801010db:	8b 45 08             	mov    0x8(%ebp),%eax
801010de:	89 50 04             	mov    %edx,0x4(%eax)
801010e1:	8b 45 08             	mov    0x8(%ebp),%eax
801010e4:	8b 40 04             	mov    0x4(%eax),%eax
801010e7:	85 c0                	test   %eax,%eax
801010e9:	7e 15                	jle    80101100 <fileclose+0x5b>
    release(&ftable.lock);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 a0 1a 19 80       	push   $0x80191aa0
801010f3:	e8 9b 36 00 00       	call   80104793 <release>
801010f8:	83 c4 10             	add    $0x10,%esp
801010fb:	e9 8b 00 00 00       	jmp    8010118b <fileclose+0xe6>
    return;
  }
  ff = *f;
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	8b 10                	mov    (%eax),%edx
80101105:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101108:	8b 50 04             	mov    0x4(%eax),%edx
8010110b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010110e:	8b 50 08             	mov    0x8(%eax),%edx
80101111:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101114:	8b 50 0c             	mov    0xc(%eax),%edx
80101117:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010111a:	8b 50 10             	mov    0x10(%eax),%edx
8010111d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101120:	8b 40 14             	mov    0x14(%eax),%eax
80101123:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101130:	8b 45 08             	mov    0x8(%ebp),%eax
80101133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	68 a0 1a 19 80       	push   $0x80191aa0
80101141:	e8 4d 36 00 00       	call   80104793 <release>
80101146:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101149:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114c:	83 f8 01             	cmp    $0x1,%eax
8010114f:	75 19                	jne    8010116a <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101151:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101155:	0f be d0             	movsbl %al,%edx
80101158:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010115b:	83 ec 08             	sub    $0x8,%esp
8010115e:	52                   	push   %edx
8010115f:	50                   	push   %eax
80101160:	e8 5a 25 00 00       	call   801036bf <pipeclose>
80101165:	83 c4 10             	add    $0x10,%esp
80101168:	eb 21                	jmp    8010118b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010116d:	83 f8 02             	cmp    $0x2,%eax
80101170:	75 19                	jne    8010118b <fileclose+0xe6>
    begin_op();
80101172:	e8 c7 1e 00 00       	call   8010303e <begin_op>
    iput(ff.ip);
80101177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	50                   	push   %eax
8010117e:	e8 d0 09 00 00       	call   80101b53 <iput>
80101183:	83 c4 10             	add    $0x10,%esp
    end_op();
80101186:	e8 3f 1f 00 00       	call   801030ca <end_op>
  }
}
8010118b:	c9                   	leave
8010118c:	c3                   	ret

8010118d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010118d:	55                   	push   %ebp
8010118e:	89 e5                	mov    %esp,%ebp
80101190:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 00                	mov    (%eax),%eax
80101198:	83 f8 02             	cmp    $0x2,%eax
8010119b:	75 40                	jne    801011dd <filestat+0x50>
    ilock(f->ip);
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	8b 40 10             	mov    0x10(%eax),%eax
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	50                   	push   %eax
801011a7:	e8 46 08 00 00       	call   801019f2 <ilock>
801011ac:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 40 10             	mov    0x10(%eax),%eax
801011b5:	83 ec 08             	sub    $0x8,%esp
801011b8:	ff 75 0c             	push   0xc(%ebp)
801011bb:	50                   	push   %eax
801011bc:	e8 d7 0c 00 00       	call   80101e98 <stati>
801011c1:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011c4:	8b 45 08             	mov    0x8(%ebp),%eax
801011c7:	8b 40 10             	mov    0x10(%eax),%eax
801011ca:	83 ec 0c             	sub    $0xc,%esp
801011cd:	50                   	push   %eax
801011ce:	e8 32 09 00 00       	call   80101b05 <iunlock>
801011d3:	83 c4 10             	add    $0x10,%esp
    return 0;
801011d6:	b8 00 00 00 00       	mov    $0x0,%eax
801011db:	eb 05                	jmp    801011e2 <filestat+0x55>
  }
  return -1;
801011dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011e2:	c9                   	leave
801011e3:	c3                   	ret

801011e4 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011e4:	55                   	push   %ebp
801011e5:	89 e5                	mov    %esp,%ebp
801011e7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ea:	8b 45 08             	mov    0x8(%ebp),%eax
801011ed:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011f1:	84 c0                	test   %al,%al
801011f3:	75 0a                	jne    801011ff <fileread+0x1b>
    return -1;
801011f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011fa:	e9 9b 00 00 00       	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 00                	mov    (%eax),%eax
80101204:	83 f8 01             	cmp    $0x1,%eax
80101207:	75 1a                	jne    80101223 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 40 0c             	mov    0xc(%eax),%eax
8010120f:	83 ec 04             	sub    $0x4,%esp
80101212:	ff 75 10             	push   0x10(%ebp)
80101215:	ff 75 0c             	push   0xc(%ebp)
80101218:	50                   	push   %eax
80101219:	e8 4e 26 00 00       	call   8010386c <piperead>
8010121e:	83 c4 10             	add    $0x10,%esp
80101221:	eb 77                	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_INODE){
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 00                	mov    (%eax),%eax
80101228:	83 f8 02             	cmp    $0x2,%eax
8010122b:	75 60                	jne    8010128d <fileread+0xa9>
    ilock(f->ip);
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 0c             	sub    $0xc,%esp
80101236:	50                   	push   %eax
80101237:	e8 b6 07 00 00       	call   801019f2 <ilock>
8010123c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010123f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 40 10             	mov    0x10(%eax),%eax
8010124e:	51                   	push   %ecx
8010124f:	52                   	push   %edx
80101250:	ff 75 0c             	push   0xc(%ebp)
80101253:	50                   	push   %eax
80101254:	e8 85 0c 00 00       	call   80101ede <readi>
80101259:	83 c4 10             	add    $0x10,%esp
8010125c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010125f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101263:	7e 11                	jle    80101276 <fileread+0x92>
      f->off += r;
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 50 14             	mov    0x14(%eax),%edx
8010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126e:	01 c2                	add    %eax,%edx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 40 10             	mov    0x10(%eax),%eax
8010127c:	83 ec 0c             	sub    $0xc,%esp
8010127f:	50                   	push   %eax
80101280:	e8 80 08 00 00       	call   80101b05 <iunlock>
80101285:	83 c4 10             	add    $0x10,%esp
    return r;
80101288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128b:	eb 0d                	jmp    8010129a <fileread+0xb6>
  }
  panic("fileread");
8010128d:	83 ec 0c             	sub    $0xc,%esp
80101290:	68 da a0 10 80       	push   $0x8010a0da
80101295:	e8 0f f3 ff ff       	call   801005a9 <panic>
}
8010129a:	c9                   	leave
8010129b:	c3                   	ret

8010129c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010129c:	55                   	push   %ebp
8010129d:	89 e5                	mov    %esp,%ebp
8010129f:	53                   	push   %ebx
801012a0:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012aa:	84 c0                	test   %al,%al
801012ac:	75 0a                	jne    801012b8 <filewrite+0x1c>
    return -1;
801012ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b3:	e9 1b 01 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 00                	mov    (%eax),%eax
801012bd:	83 f8 01             	cmp    $0x1,%eax
801012c0:	75 1d                	jne    801012df <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 40 0c             	mov    0xc(%eax),%eax
801012c8:	83 ec 04             	sub    $0x4,%esp
801012cb:	ff 75 10             	push   0x10(%ebp)
801012ce:	ff 75 0c             	push   0xc(%ebp)
801012d1:	50                   	push   %eax
801012d2:	e8 93 24 00 00       	call   8010376a <pipewrite>
801012d7:	83 c4 10             	add    $0x10,%esp
801012da:	e9 f4 00 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_INODE){
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 00                	mov    (%eax),%eax
801012e4:	83 f8 02             	cmp    $0x2,%eax
801012e7:	0f 85 d9 00 00 00    	jne    801013c6 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012ed:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012fb:	e9 a3 00 00 00       	jmp    801013a3 <filewrite+0x107>
      int n1 = n - i;
80101300:	8b 45 10             	mov    0x10(%ebp),%eax
80101303:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101306:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010130c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010130f:	7e 06                	jle    80101317 <filewrite+0x7b>
        n1 = max;
80101311:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101314:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101317:	e8 22 1d 00 00       	call   8010303e <begin_op>
      ilock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 c7 06 00 00       	call   801019f2 <ilock>
8010132b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010132e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	01 c3                	add    %eax,%ebx
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	8b 40 10             	mov    0x10(%eax),%eax
80101345:	51                   	push   %ecx
80101346:	52                   	push   %edx
80101347:	53                   	push   %ebx
80101348:	50                   	push   %eax
80101349:	e8 e5 0c 00 00       	call   80102033 <writei>
8010134e:	83 c4 10             	add    $0x10,%esp
80101351:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101354:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101358:	7e 11                	jle    8010136b <filewrite+0xcf>
        f->off += r;
8010135a:	8b 45 08             	mov    0x8(%ebp),%eax
8010135d:	8b 50 14             	mov    0x14(%eax),%edx
80101360:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101363:	01 c2                	add    %eax,%edx
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	8b 40 10             	mov    0x10(%eax),%eax
80101371:	83 ec 0c             	sub    $0xc,%esp
80101374:	50                   	push   %eax
80101375:	e8 8b 07 00 00       	call   80101b05 <iunlock>
8010137a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010137d:	e8 48 1d 00 00       	call   801030ca <end_op>

      if(r < 0)
80101382:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101386:	78 29                	js     801013b1 <filewrite+0x115>
        break;
      if(r != n1)
80101388:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010138e:	74 0d                	je     8010139d <filewrite+0x101>
        panic("short filewrite");
80101390:	83 ec 0c             	sub    $0xc,%esp
80101393:	68 e3 a0 10 80       	push   $0x8010a0e3
80101398:	e8 0c f2 ff ff       	call   801005a9 <panic>
      i += r;
8010139d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a0:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a9:	0f 8c 51 ff ff ff    	jl     80101300 <filewrite+0x64>
801013af:	eb 01                	jmp    801013b2 <filewrite+0x116>
        break;
801013b1:	90                   	nop
    }
    return i == n ? n : -1;
801013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013b8:	75 05                	jne    801013bf <filewrite+0x123>
801013ba:	8b 45 10             	mov    0x10(%ebp),%eax
801013bd:	eb 14                	jmp    801013d3 <filewrite+0x137>
801013bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c4:	eb 0d                	jmp    801013d3 <filewrite+0x137>
  }
  panic("filewrite");
801013c6:	83 ec 0c             	sub    $0xc,%esp
801013c9:	68 f3 a0 10 80       	push   $0x8010a0f3
801013ce:	e8 d6 f1 ff ff       	call   801005a9 <panic>
}
801013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013d6:	c9                   	leave
801013d7:	c3                   	ret

801013d8 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013d8:	55                   	push   %ebp
801013d9:	89 e5                	mov    %esp,%ebp
801013db:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	83 ec 08             	sub    $0x8,%esp
801013e4:	6a 01                	push   $0x1
801013e6:	50                   	push   %eax
801013e7:	e8 15 ee ff ff       	call   80100201 <bread>
801013ec:	83 c4 10             	add    $0x10,%esp
801013ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f5:	83 c0 5c             	add    $0x5c,%eax
801013f8:	83 ec 04             	sub    $0x4,%esp
801013fb:	6a 1c                	push   $0x1c
801013fd:	50                   	push   %eax
801013fe:	ff 75 0c             	push   0xc(%ebp)
80101401:	e8 54 36 00 00       	call   80104a5a <memmove>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	push   -0xc(%ebp)
8010140f:	e8 6f ee ff ff       	call   80100283 <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave
80101419:	c3                   	ret

8010141a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101420:	8b 55 0c             	mov    0xc(%ebp),%edx
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	83 ec 08             	sub    $0x8,%esp
80101429:	52                   	push   %edx
8010142a:	50                   	push   %eax
8010142b:	e8 d1 ed ff ff       	call   80100201 <bread>
80101430:	83 c4 10             	add    $0x10,%esp
80101433:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101439:	83 c0 5c             	add    $0x5c,%eax
8010143c:	83 ec 04             	sub    $0x4,%esp
8010143f:	68 00 02 00 00       	push   $0x200
80101444:	6a 00                	push   $0x0
80101446:	50                   	push   %eax
80101447:	e8 4f 35 00 00       	call   8010499b <memset>
8010144c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010144f:	83 ec 0c             	sub    $0xc,%esp
80101452:	ff 75 f4             	push   -0xc(%ebp)
80101455:	e8 1d 1e 00 00       	call   80103277 <log_write>
8010145a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010145d:	83 ec 0c             	sub    $0xc,%esp
80101460:	ff 75 f4             	push   -0xc(%ebp)
80101463:	e8 1b ee ff ff       	call   80100283 <brelse>
80101468:	83 c4 10             	add    $0x10,%esp
}
8010146b:	90                   	nop
8010146c:	c9                   	leave
8010146d:	c3                   	ret

8010146e <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010146e:	55                   	push   %ebp
8010146f:	89 e5                	mov    %esp,%ebp
80101471:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101474:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010147b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101482:	e9 0b 01 00 00       	jmp    80101592 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101490:	85 c0                	test   %eax,%eax
80101492:	0f 48 c2             	cmovs  %edx,%eax
80101495:	c1 f8 0c             	sar    $0xc,%eax
80101498:	89 c2                	mov    %eax,%edx
8010149a:	a1 58 24 19 80       	mov    0x80192458,%eax
8010149f:	01 d0                	add    %edx,%eax
801014a1:	83 ec 08             	sub    $0x8,%esp
801014a4:	50                   	push   %eax
801014a5:	ff 75 08             	push   0x8(%ebp)
801014a8:	e8 54 ed ff ff       	call   80100201 <bread>
801014ad:	83 c4 10             	add    $0x10,%esp
801014b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014ba:	e9 9e 00 00 00       	jmp    8010155d <balloc+0xef>
      m = 1 << (bi % 8);
801014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c2:	83 e0 07             	and    $0x7,%eax
801014c5:	ba 01 00 00 00       	mov    $0x1,%edx
801014ca:	89 c1                	mov    %eax,%ecx
801014cc:	d3 e2                	shl    %cl,%edx
801014ce:	89 d0                	mov    %edx,%eax
801014d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	8d 50 07             	lea    0x7(%eax),%edx
801014d9:	85 c0                	test   %eax,%eax
801014db:	0f 48 c2             	cmovs  %edx,%eax
801014de:	c1 f8 03             	sar    $0x3,%eax
801014e1:	89 c2                	mov    %eax,%edx
801014e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014e6:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014eb:	0f b6 c0             	movzbl %al,%eax
801014ee:	23 45 e8             	and    -0x18(%ebp),%eax
801014f1:	85 c0                	test   %eax,%eax
801014f3:	75 64                	jne    80101559 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f8:	8d 50 07             	lea    0x7(%eax),%edx
801014fb:	85 c0                	test   %eax,%eax
801014fd:	0f 48 c2             	cmovs  %edx,%eax
80101500:	c1 f8 03             	sar    $0x3,%eax
80101503:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101506:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010150b:	89 d1                	mov    %edx,%ecx
8010150d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101510:	09 ca                	or     %ecx,%edx
80101512:	89 d1                	mov    %edx,%ecx
80101514:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101517:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010151b:	83 ec 0c             	sub    $0xc,%esp
8010151e:	ff 75 ec             	push   -0x14(%ebp)
80101521:	e8 51 1d 00 00       	call   80103277 <log_write>
80101526:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101529:	83 ec 0c             	sub    $0xc,%esp
8010152c:	ff 75 ec             	push   -0x14(%ebp)
8010152f:	e8 4f ed ff ff       	call   80100283 <brelse>
80101534:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	01 c2                	add    %eax,%edx
8010153f:	8b 45 08             	mov    0x8(%ebp),%eax
80101542:	83 ec 08             	sub    $0x8,%esp
80101545:	52                   	push   %edx
80101546:	50                   	push   %eax
80101547:	e8 ce fe ff ff       	call   8010141a <bzero>
8010154c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	01 d0                	add    %edx,%eax
80101557:	eb 56                	jmp    801015af <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101559:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010155d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101564:	7f 17                	jg     8010157d <balloc+0x10f>
80101566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	01 d0                	add    %edx,%eax
8010156e:	89 c2                	mov    %eax,%edx
80101570:	a1 40 24 19 80       	mov    0x80192440,%eax
80101575:	39 c2                	cmp    %eax,%edx
80101577:	0f 82 42 ff ff ff    	jb     801014bf <balloc+0x51>
      }
    }
    brelse(bp);
8010157d:	83 ec 0c             	sub    $0xc,%esp
80101580:	ff 75 ec             	push   -0x14(%ebp)
80101583:	e8 fb ec ff ff       	call   80100283 <brelse>
80101588:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010158b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101592:	a1 40 24 19 80       	mov    0x80192440,%eax
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	39 c2                	cmp    %eax,%edx
8010159c:	0f 82 e5 fe ff ff    	jb     80101487 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a2:	83 ec 0c             	sub    $0xc,%esp
801015a5:	68 00 a1 10 80       	push   $0x8010a100
801015aa:	e8 fa ef ff ff       	call   801005a9 <panic>
}
801015af:	c9                   	leave
801015b0:	c3                   	ret

801015b1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015b1:	55                   	push   %ebp
801015b2:	89 e5                	mov    %esp,%ebp
801015b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015b7:	83 ec 08             	sub    $0x8,%esp
801015ba:	68 40 24 19 80       	push   $0x80192440
801015bf:	ff 75 08             	push   0x8(%ebp)
801015c2:	e8 11 fe ff ff       	call   801013d8 <readsb>
801015c7:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cd:	c1 e8 0c             	shr    $0xc,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	a1 58 24 19 80       	mov    0x80192458,%eax
801015d7:	01 c2                	add    %eax,%edx
801015d9:	8b 45 08             	mov    0x8(%ebp),%eax
801015dc:	83 ec 08             	sub    $0x8,%esp
801015df:	52                   	push   %edx
801015e0:	50                   	push   %eax
801015e1:	e8 1b ec ff ff       	call   80100201 <bread>
801015e6:	83 c4 10             	add    $0x10,%esp
801015e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ef:	25 ff 0f 00 00       	and    $0xfff,%eax
801015f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	83 e0 07             	and    $0x7,%eax
801015fd:	ba 01 00 00 00       	mov    $0x1,%edx
80101602:	89 c1                	mov    %eax,%ecx
80101604:	d3 e2                	shl    %cl,%edx
80101606:	89 d0                	mov    %edx,%eax
80101608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160e:	8d 50 07             	lea    0x7(%eax),%edx
80101611:	85 c0                	test   %eax,%eax
80101613:	0f 48 c2             	cmovs  %edx,%eax
80101616:	c1 f8 03             	sar    $0x3,%eax
80101619:	89 c2                	mov    %eax,%edx
8010161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101623:	0f b6 c0             	movzbl %al,%eax
80101626:	23 45 ec             	and    -0x14(%ebp),%eax
80101629:	85 c0                	test   %eax,%eax
8010162b:	75 0d                	jne    8010163a <bfree+0x89>
    panic("freeing free block");
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	68 16 a1 10 80       	push   $0x8010a116
80101635:	e8 6f ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
8010163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163d:	8d 50 07             	lea    0x7(%eax),%edx
80101640:	85 c0                	test   %eax,%eax
80101642:	0f 48 c2             	cmovs  %edx,%eax
80101645:	c1 f8 03             	sar    $0x3,%eax
80101648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164b:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101655:	f7 d2                	not    %edx
80101657:	21 ca                	and    %ecx,%edx
80101659:	89 d1                	mov    %edx,%ecx
8010165b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101662:	83 ec 0c             	sub    $0xc,%esp
80101665:	ff 75 f4             	push   -0xc(%ebp)
80101668:	e8 0a 1c 00 00       	call   80103277 <log_write>
8010166d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101670:	83 ec 0c             	sub    $0xc,%esp
80101673:	ff 75 f4             	push   -0xc(%ebp)
80101676:	e8 08 ec ff ff       	call   80100283 <brelse>
8010167b:	83 c4 10             	add    $0x10,%esp
}
8010167e:	90                   	nop
8010167f:	c9                   	leave
80101680:	c3                   	ret

80101681 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101681:	55                   	push   %ebp
80101682:	89 e5                	mov    %esp,%ebp
80101684:	57                   	push   %edi
80101685:	56                   	push   %esi
80101686:	53                   	push   %ebx
80101687:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010168a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101691:	83 ec 08             	sub    $0x8,%esp
80101694:	68 29 a1 10 80       	push   $0x8010a129
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 60 30 00 00       	call   80104703 <initlock>
801016a3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016ad:	eb 2d                	jmp    801016dc <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016b2:	89 d0                	mov    %edx,%eax
801016b4:	c1 e0 03             	shl    $0x3,%eax
801016b7:	01 d0                	add    %edx,%eax
801016b9:	c1 e0 04             	shl    $0x4,%eax
801016bc:	83 c0 30             	add    $0x30,%eax
801016bf:	05 60 24 19 80       	add    $0x80192460,%eax
801016c4:	83 c0 10             	add    $0x10,%eax
801016c7:	83 ec 08             	sub    $0x8,%esp
801016ca:	68 30 a1 10 80       	push   $0x8010a130
801016cf:	50                   	push   %eax
801016d0:	e8 d1 2e 00 00       	call   801045a6 <initsleeplock>
801016d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016dc:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e0:	7e cd                	jle    801016af <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	68 40 24 19 80       	push   $0x80192440
801016ea:	ff 75 08             	push   0x8(%ebp)
801016ed:	e8 e6 fc ff ff       	call   801013d8 <readsb>
801016f2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016f5:	a1 58 24 19 80       	mov    0x80192458,%eax
801016fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016fd:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
80101703:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101709:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
8010170f:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
80101715:	8b 15 44 24 19 80    	mov    0x80192444,%edx
8010171b:	a1 40 24 19 80       	mov    0x80192440,%eax
80101720:	ff 75 d4             	push   -0x2c(%ebp)
80101723:	57                   	push   %edi
80101724:	56                   	push   %esi
80101725:	53                   	push   %ebx
80101726:	51                   	push   %ecx
80101727:	52                   	push   %edx
80101728:	50                   	push   %eax
80101729:	68 38 a1 10 80       	push   $0x8010a138
8010172e:	e8 c1 ec ff ff       	call   801003f4 <cprintf>
80101733:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101736:	90                   	nop
80101737:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010173a:	5b                   	pop    %ebx
8010173b:	5e                   	pop    %esi
8010173c:	5f                   	pop    %edi
8010173d:	5d                   	pop    %ebp
8010173e:	c3                   	ret

8010173f <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010173f:	55                   	push   %ebp
80101740:	89 e5                	mov    %esp,%ebp
80101742:	83 ec 28             	sub    $0x28,%esp
80101745:	8b 45 0c             	mov    0xc(%ebp),%eax
80101748:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010174c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101753:	e9 9e 00 00 00       	jmp    801017f6 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175b:	c1 e8 03             	shr    $0x3,%eax
8010175e:	89 c2                	mov    %eax,%edx
80101760:	a1 54 24 19 80       	mov    0x80192454,%eax
80101765:	01 d0                	add    %edx,%eax
80101767:	83 ec 08             	sub    $0x8,%esp
8010176a:	50                   	push   %eax
8010176b:	ff 75 08             	push   0x8(%ebp)
8010176e:	e8 8e ea ff ff       	call   80100201 <bread>
80101773:	83 c4 10             	add    $0x10,%esp
80101776:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101782:	83 e0 07             	and    $0x7,%eax
80101785:	c1 e0 06             	shl    $0x6,%eax
80101788:	01 d0                	add    %edx,%eax
8010178a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010178d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101790:	0f b7 00             	movzwl (%eax),%eax
80101793:	66 85 c0             	test   %ax,%ax
80101796:	75 4c                	jne    801017e4 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101798:	83 ec 04             	sub    $0x4,%esp
8010179b:	6a 40                	push   $0x40
8010179d:	6a 00                	push   $0x0
8010179f:	ff 75 ec             	push   -0x14(%ebp)
801017a2:	e8 f4 31 00 00       	call   8010499b <memset>
801017a7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ad:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f0             	push   -0x10(%ebp)
801017ba:	e8 b8 1a 00 00       	call   80103277 <log_write>
801017bf:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017c2:	83 ec 0c             	sub    $0xc,%esp
801017c5:	ff 75 f0             	push   -0x10(%ebp)
801017c8:	e8 b6 ea ff ff       	call   80100283 <brelse>
801017cd:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	50                   	push   %eax
801017d7:	ff 75 08             	push   0x8(%ebp)
801017da:	e8 f7 00 00 00       	call   801018d6 <iget>
801017df:	83 c4 10             	add    $0x10,%esp
801017e2:	eb 2f                	jmp    80101813 <ialloc+0xd4>
    }
    brelse(bp);
801017e4:	83 ec 0c             	sub    $0xc,%esp
801017e7:	ff 75 f0             	push   -0x10(%ebp)
801017ea:	e8 94 ea ff ff       	call   80100283 <brelse>
801017ef:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017f6:	a1 48 24 19 80       	mov    0x80192448,%eax
801017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 52 ff ff ff    	jb     80101758 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 8b a1 10 80       	push   $0x8010a18b
8010180e:	e8 96 ed ff ff       	call   801005a9 <panic>
}
80101813:	c9                   	leave
80101814:	c3                   	ret

80101815 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101815:	55                   	push   %ebp
80101816:	89 e5                	mov    %esp,%ebp
80101818:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8b 40 04             	mov    0x4(%eax),%eax
80101821:	c1 e8 03             	shr    $0x3,%eax
80101824:	89 c2                	mov    %eax,%edx
80101826:	a1 54 24 19 80       	mov    0x80192454,%eax
8010182b:	01 c2                	add    %eax,%edx
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 00                	mov    (%eax),%eax
80101832:	83 ec 08             	sub    $0x8,%esp
80101835:	52                   	push   %edx
80101836:	50                   	push   %eax
80101837:	e8 c5 e9 ff ff       	call   80100201 <bread>
8010183c:	83 c4 10             	add    $0x10,%esp
8010183f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	8d 50 5c             	lea    0x5c(%eax),%edx
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 04             	mov    0x4(%eax),%eax
8010184e:	83 e0 07             	and    $0x7,%eax
80101851:	c1 e0 06             	shl    $0x6,%eax
80101854:	01 d0                	add    %edx,%eax
80101856:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101863:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101866:	8b 45 08             	mov    0x8(%ebp),%eax
80101869:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101870:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101882:	8b 45 08             	mov    0x8(%ebp),%eax
80101885:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 50 58             	mov    0x58(%eax),%edx
80101896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101899:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a5:	83 c0 0c             	add    $0xc,%eax
801018a8:	83 ec 04             	sub    $0x4,%esp
801018ab:	6a 34                	push   $0x34
801018ad:	52                   	push   %edx
801018ae:	50                   	push   %eax
801018af:	e8 a6 31 00 00       	call   80104a5a <memmove>
801018b4:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	ff 75 f4             	push   -0xc(%ebp)
801018bd:	e8 b5 19 00 00       	call   80103277 <log_write>
801018c2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018c5:	83 ec 0c             	sub    $0xc,%esp
801018c8:	ff 75 f4             	push   -0xc(%ebp)
801018cb:	e8 b3 e9 ff ff       	call   80100283 <brelse>
801018d0:	83 c4 10             	add    $0x10,%esp
}
801018d3:	90                   	nop
801018d4:	c9                   	leave
801018d5:	c3                   	ret

801018d6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018d6:	55                   	push   %ebp
801018d7:	89 e5                	mov    %esp,%ebp
801018d9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018dc:	83 ec 0c             	sub    $0xc,%esp
801018df:	68 60 24 19 80       	push   $0x80192460
801018e4:	e8 3c 2e 00 00       	call   80104725 <acquire>
801018e9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f3:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018fa:	eb 60                	jmp    8010195c <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ff:	8b 40 08             	mov    0x8(%eax),%eax
80101902:	85 c0                	test   %eax,%eax
80101904:	7e 39                	jle    8010193f <iget+0x69>
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8b 00                	mov    (%eax),%eax
8010190b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010190e:	75 2f                	jne    8010193f <iget+0x69>
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101913:	8b 40 04             	mov    0x4(%eax),%eax
80101916:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101919:	75 24                	jne    8010193f <iget+0x69>
      ip->ref++;
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 40 08             	mov    0x8(%eax),%eax
80101921:	8d 50 01             	lea    0x1(%eax),%edx
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010192a:	83 ec 0c             	sub    $0xc,%esp
8010192d:	68 60 24 19 80       	push   $0x80192460
80101932:	e8 5c 2e 00 00       	call   80104793 <release>
80101937:	83 c4 10             	add    $0x10,%esp
      return ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193d:	eb 77                	jmp    801019b6 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010193f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101943:	75 10                	jne    80101955 <iget+0x7f>
80101945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101948:	8b 40 08             	mov    0x8(%eax),%eax
8010194b:	85 c0                	test   %eax,%eax
8010194d:	75 06                	jne    80101955 <iget+0x7f>
      empty = ip;
8010194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101955:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010195c:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101963:	72 97                	jb     801018fc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101965:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101969:	75 0d                	jne    80101978 <iget+0xa2>
    panic("iget: no inodes");
8010196b:	83 ec 0c             	sub    $0xc,%esp
8010196e:	68 9d a1 10 80       	push   $0x8010a19d
80101973:	e8 31 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 08             	mov    0x8(%ebp),%edx
80101984:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010198c:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019a3:	83 ec 0c             	sub    $0xc,%esp
801019a6:	68 60 24 19 80       	push   $0x80192460
801019ab:	e8 e3 2d 00 00       	call   80104793 <release>
801019b0:	83 c4 10             	add    $0x10,%esp

  return ip;
801019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019b6:	c9                   	leave
801019b7:	c3                   	ret

801019b8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b8:	55                   	push   %ebp
801019b9:	89 e5                	mov    %esp,%ebp
801019bb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019be:	83 ec 0c             	sub    $0xc,%esp
801019c1:	68 60 24 19 80       	push   $0x80192460
801019c6:	e8 5a 2d 00 00       	call   80104725 <acquire>
801019cb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 08             	mov    0x8(%eax),%eax
801019d4:	8d 50 01             	lea    0x1(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 60 24 19 80       	push   $0x80192460
801019e5:	e8 a9 2d 00 00       	call   80104793 <release>
801019ea:	83 c4 10             	add    $0x10,%esp
  return ip;
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019f0:	c9                   	leave
801019f1:	c3                   	ret

801019f2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019f2:	55                   	push   %ebp
801019f3:	89 e5                	mov    %esp,%ebp
801019f5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019fc:	74 0a                	je     80101a08 <ilock+0x16>
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	8b 40 08             	mov    0x8(%eax),%eax
80101a04:	85 c0                	test   %eax,%eax
80101a06:	7f 0d                	jg     80101a15 <ilock+0x23>
    panic("ilock");
80101a08:	83 ec 0c             	sub    $0xc,%esp
80101a0b:	68 ad a1 10 80       	push   $0x8010a1ad
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 be 2b 00 00       	call   801045e2 <acquiresleep>
80101a24:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a2d:	85 c0                	test   %eax,%eax
80101a2f:	0f 85 cd 00 00 00    	jne    80101b02 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	8b 40 04             	mov    0x4(%eax),%eax
80101a3b:	c1 e8 03             	shr    $0x3,%eax
80101a3e:	89 c2                	mov    %eax,%edx
80101a40:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a45:	01 c2                	add    %eax,%edx
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	8b 00                	mov    (%eax),%eax
80101a4c:	83 ec 08             	sub    $0x8,%esp
80101a4f:	52                   	push   %edx
80101a50:	50                   	push   %eax
80101a51:	e8 ab e7 ff ff       	call   80100201 <bread>
80101a56:	83 c4 10             	add    $0x10,%esp
80101a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	8b 40 04             	mov    0x4(%eax),%eax
80101a68:	83 e0 07             	and    $0x7,%eax
80101a6b:	c1 e0 06             	shl    $0x6,%eax
80101a6e:	01 d0                	add    %edx,%eax
80101a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	0f b7 10             	movzwl (%eax),%edx
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a83:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a91:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aad:	8b 50 08             	mov    0x8(%eax),%edx
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab9:	8d 50 0c             	lea    0xc(%eax),%edx
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	83 c0 5c             	add    $0x5c,%eax
80101ac2:	83 ec 04             	sub    $0x4,%esp
80101ac5:	6a 34                	push   $0x34
80101ac7:	52                   	push   %edx
80101ac8:	50                   	push   %eax
80101ac9:	e8 8c 2f 00 00       	call   80104a5a <memmove>
80101ace:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ad1:	83 ec 0c             	sub    $0xc,%esp
80101ad4:	ff 75 f4             	push   -0xc(%ebp)
80101ad7:	e8 a7 e7 ff ff       	call   80100283 <brelse>
80101adc:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101af0:	66 85 c0             	test   %ax,%ax
80101af3:	75 0d                	jne    80101b02 <ilock+0x110>
      panic("ilock: no type");
80101af5:	83 ec 0c             	sub    $0xc,%esp
80101af8:	68 b3 a1 10 80       	push   $0x8010a1b3
80101afd:	e8 a7 ea ff ff       	call   801005a9 <panic>
  }
}
80101b02:	90                   	nop
80101b03:	c9                   	leave
80101b04:	c3                   	ret

80101b05 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b05:	55                   	push   %ebp
80101b06:	89 e5                	mov    %esp,%ebp
80101b08:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b0f:	74 20                	je     80101b31 <iunlock+0x2c>
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	83 c0 0c             	add    $0xc,%eax
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	50                   	push   %eax
80101b1b:	e8 74 2b 00 00       	call   80104694 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 c2 a1 10 80       	push   $0x8010a1c2
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 f9 2a 00 00       	call   80104646 <releasesleep>
80101b4d:	83 c4 10             	add    $0x10,%esp
}
80101b50:	90                   	nop
80101b51:	c9                   	leave
80101b52:	c3                   	ret

80101b53 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b53:	55                   	push   %ebp
80101b54:	89 e5                	mov    %esp,%ebp
80101b56:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	83 c0 0c             	add    $0xc,%eax
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	50                   	push   %eax
80101b63:	e8 7a 2a 00 00       	call   801045e2 <acquiresleep>
80101b68:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 6a                	je     80101bdf <iput+0x8c>
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b7c:	66 85 c0             	test   %ax,%ax
80101b7f:	75 5e                	jne    80101bdf <iput+0x8c>
    acquire(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 60 24 19 80       	push   $0x80192460
80101b89:	e8 97 2b 00 00       	call   80104725 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 ec 2b 00 00       	call   80104793 <release>
80101ba7:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101baa:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bae:	75 2f                	jne    80101bdf <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	ff 75 08             	push   0x8(%ebp)
80101bb6:	e8 ad 01 00 00       	call   80101d68 <itrunc>
80101bbb:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc7:	83 ec 0c             	sub    $0xc,%esp
80101bca:	ff 75 08             	push   0x8(%ebp)
80101bcd:	e8 43 fc ff ff       	call   80101815 <iupdate>
80101bd2:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101be2:	83 c0 0c             	add    $0xc,%eax
80101be5:	83 ec 0c             	sub    $0xc,%esp
80101be8:	50                   	push   %eax
80101be9:	e8 58 2a 00 00       	call   80104646 <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 27 2b 00 00       	call   80104725 <acquire>
80101bfe:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 08             	mov    0x8(%eax),%eax
80101c07:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 60 24 19 80       	push   $0x80192460
80101c18:	e8 76 2b 00 00       	call   80104793 <release>
80101c1d:	83 c4 10             	add    $0x10,%esp
}
80101c20:	90                   	nop
80101c21:	c9                   	leave
80101c22:	c3                   	ret

80101c23 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c23:	55                   	push   %ebp
80101c24:	89 e5                	mov    %esp,%ebp
80101c26:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c29:	83 ec 0c             	sub    $0xc,%esp
80101c2c:	ff 75 08             	push   0x8(%ebp)
80101c2f:	e8 d1 fe ff ff       	call   80101b05 <iunlock>
80101c34:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	ff 75 08             	push   0x8(%ebp)
80101c3d:	e8 11 ff ff ff       	call   80101b53 <iput>
80101c42:	83 c4 10             	add    $0x10,%esp
}
80101c45:	90                   	nop
80101c46:	c9                   	leave
80101c47:	c3                   	ret

80101c48 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c48:	55                   	push   %ebp
80101c49:	89 e5                	mov    %esp,%ebp
80101c4b:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c4e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c52:	77 42                	ja     80101c96 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c5a:	83 c2 14             	add    $0x14,%edx
80101c5d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c68:	75 24                	jne    80101c8e <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	8b 00                	mov    (%eax),%eax
80101c6f:	83 ec 0c             	sub    $0xc,%esp
80101c72:	50                   	push   %eax
80101c73:	e8 f6 f7 ff ff       	call   8010146e <balloc>
80101c78:	83 c4 10             	add    $0x10,%esp
80101c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c84:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c8a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c91:	e9 d0 00 00 00       	jmp    80101d66 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c96:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c9a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c9e:	0f 87 b5 00 00 00    	ja     80101d59 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb4:	75 20                	jne    80101cd6 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	50                   	push   %eax
80101cbf:	e8 aa f7 ff ff       	call   8010146e <balloc>
80101cc4:	83 c4 10             	add    $0x10,%esp
80101cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd0:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	8b 00                	mov    (%eax),%eax
80101cdb:	83 ec 08             	sub    $0x8,%esp
80101cde:	ff 75 f4             	push   -0xc(%ebp)
80101ce1:	50                   	push   %eax
80101ce2:	e8 1a e5 ff ff       	call   80100201 <bread>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf0:	83 c0 5c             	add    $0x5c,%eax
80101cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d03:	01 d0                	add    %edx,%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d0e:	75 36                	jne    80101d46 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d10:	8b 45 08             	mov    0x8(%ebp),%eax
80101d13:	8b 00                	mov    (%eax),%eax
80101d15:	83 ec 0c             	sub    $0xc,%esp
80101d18:	50                   	push   %eax
80101d19:	e8 50 f7 ff ff       	call   8010146e <balloc>
80101d1e:	83 c4 10             	add    $0x10,%esp
80101d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d31:	01 c2                	add    %eax,%edx
80101d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d36:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d38:	83 ec 0c             	sub    $0xc,%esp
80101d3b:	ff 75 f0             	push   -0x10(%ebp)
80101d3e:	e8 34 15 00 00       	call   80103277 <log_write>
80101d43:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	ff 75 f0             	push   -0x10(%ebp)
80101d4c:	e8 32 e5 ff ff       	call   80100283 <brelse>
80101d51:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d57:	eb 0d                	jmp    80101d66 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	68 ca a1 10 80       	push   $0x8010a1ca
80101d61:	e8 43 e8 ff ff       	call   801005a9 <panic>
}
80101d66:	c9                   	leave
80101d67:	c3                   	ret

80101d68 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d75:	eb 45                	jmp    80101dbc <itrunc+0x54>
    if(ip->addrs[i]){
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7d:	83 c2 14             	add    $0x14,%edx
80101d80:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d84:	85 c0                	test   %eax,%eax
80101d86:	74 30                	je     80101db8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8e:	83 c2 14             	add    $0x14,%edx
80101d91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d95:	8b 55 08             	mov    0x8(%ebp),%edx
80101d98:	8b 12                	mov    (%edx),%edx
80101d9a:	83 ec 08             	sub    $0x8,%esp
80101d9d:	50                   	push   %eax
80101d9e:	52                   	push   %edx
80101d9f:	e8 0d f8 ff ff       	call   801015b1 <bfree>
80101da4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da7:	8b 45 08             	mov    0x8(%ebp),%eax
80101daa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dad:	83 c2 14             	add    $0x14,%edx
80101db0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db7:	00 
  for(i = 0; i < NDIRECT; i++){
80101db8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dbc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc0:	7e b5                	jle    80101d77 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dcb:	85 c0                	test   %eax,%eax
80101dcd:	0f 84 aa 00 00 00    	je     80101e7d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 16 e4 ff ff       	call   80100201 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 5c             	add    $0x5c,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd7>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 79 f7 ff ff       	call   801015b1 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x9b>
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	push   -0x14(%ebp)
80101e4d:	e8 31 e4 ff ff       	call   80100283 <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e61:	8b 12                	mov    (%edx),%edx
80101e63:	83 ec 08             	sub    $0x8,%esp
80101e66:	50                   	push   %eax
80101e67:	52                   	push   %edx
80101e68:	e8 44 f7 ff ff       	call   801015b1 <bfree>
80101e6d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e7a:	00 00 00 
  }

  ip->size = 0;
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e87:	83 ec 0c             	sub    $0xc,%esp
80101e8a:	ff 75 08             	push   0x8(%ebp)
80101e8d:	e8 83 f9 ff ff       	call   80101815 <iupdate>
80101e92:	83 c4 10             	add    $0x10,%esp
}
80101e95:	90                   	nop
80101e96:	c9                   	leave
80101e97:	c3                   	ret

80101e98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e98:	55                   	push   %ebp
80101e99:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 00                	mov    (%eax),%eax
80101ea0:	89 c2                	mov    %eax,%edx
80101ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	8b 50 04             	mov    0x4(%eax),%edx
80101eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 50 58             	mov    0x58(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edb:	90                   	nop
80101edc:	5d                   	pop    %ebp
80101edd:	c3                   	ret

80101ede <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ede:	55                   	push   %ebp
80101edf:	89 e5                	mov    %esp,%ebp
80101ee1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101eeb:	66 83 f8 03          	cmp    $0x3,%ax
80101eef:	75 5c                	jne    80101f4d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef8:	66 85 c0             	test   %ax,%ax
80101efb:	78 20                	js     80101f1d <readi+0x3f>
80101efd:	8b 45 08             	mov    0x8(%ebp),%eax
80101f00:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f04:	66 83 f8 09          	cmp    $0x9,%ax
80101f08:	7f 13                	jg     80101f1d <readi+0x3f>
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f11:	98                   	cwtl
80101f12:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0a 01 00 00       	jmp    80102031 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2e:	98                   	cwtl
80101f2f:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f36:	8b 55 14             	mov    0x14(%ebp),%edx
80101f39:	83 ec 04             	sub    $0x4,%esp
80101f3c:	52                   	push   %edx
80101f3d:	ff 75 0c             	push   0xc(%ebp)
80101f40:	ff 75 08             	push   0x8(%ebp)
80101f43:	ff d0                	call   *%eax
80101f45:	83 c4 10             	add    $0x10,%esp
80101f48:	e9 e4 00 00 00       	jmp    80102031 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 40 58             	mov    0x58(%eax),%eax
80101f53:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f56:	72 0d                	jb     80101f65 <readi+0x87>
80101f58:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5e:	01 d0                	add    %edx,%eax
80101f60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f63:	73 0a                	jae    80101f6f <readi+0x91>
    return -1;
80101f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6a:	e9 c2 00 00 00       	jmp    80102031 <readi+0x153>
  if(off + n > ip->size)
80101f6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f72:	8b 45 14             	mov    0x14(%ebp),%eax
80101f75:	01 c2                	add    %eax,%edx
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	8b 40 58             	mov    0x58(%eax),%eax
80101f7d:	39 d0                	cmp    %edx,%eax
80101f7f:	73 0c                	jae    80101f8d <readi+0xaf>
    n = ip->size - off;
80101f81:	8b 45 08             	mov    0x8(%ebp),%eax
80101f84:	8b 40 58             	mov    0x58(%eax),%eax
80101f87:	2b 45 10             	sub    0x10(%ebp),%eax
80101f8a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f94:	e9 89 00 00 00       	jmp    80102022 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f99:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9c:	c1 e8 09             	shr    $0x9,%eax
80101f9f:	83 ec 08             	sub    $0x8,%esp
80101fa2:	50                   	push   %eax
80101fa3:	ff 75 08             	push   0x8(%ebp)
80101fa6:	e8 9d fc ff ff       	call   80101c48 <bmap>
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb1:	8b 12                	mov    (%edx),%edx
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	52                   	push   %edx
80101fb8:	e8 44 e2 ff ff       	call   80100201 <bread>
80101fbd:	83 c4 10             	add    $0x10,%esp
80101fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcb:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd0:	29 c2                	sub    %eax,%edx
80101fd2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd8:	39 c2                	cmp    %eax,%edx
80101fda:	0f 46 c2             	cmovbe %edx,%eax
80101fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fee:	01 d0                	add    %edx,%eax
80101ff0:	83 ec 04             	sub    $0x4,%esp
80101ff3:	ff 75 ec             	push   -0x14(%ebp)
80101ff6:	50                   	push   %eax
80101ff7:	ff 75 0c             	push   0xc(%ebp)
80101ffa:	e8 5b 2a 00 00       	call   80104a5a <memmove>
80101fff:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	ff 75 f0             	push   -0x10(%ebp)
80102008:	e8 76 e2 ff ff       	call   80100283 <brelse>
8010200d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102013:	01 45 f4             	add    %eax,-0xc(%ebp)
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 10             	add    %eax,0x10(%ebp)
8010201c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201f:	01 45 0c             	add    %eax,0xc(%ebp)
80102022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102025:	3b 45 14             	cmp    0x14(%ebp),%eax
80102028:	0f 82 6b ff ff ff    	jb     80101f99 <readi+0xbb>
  }
  return n;
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102031:	c9                   	leave
80102032:	c3                   	ret

80102033 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102040:	66 83 f8 03          	cmp    $0x3,%ax
80102044:	75 5c                	jne    801020a2 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204d:	66 85 c0             	test   %ax,%ax
80102050:	78 20                	js     80102072 <writei+0x3f>
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102059:	66 83 f8 09          	cmp    $0x9,%ax
8010205d:	7f 13                	jg     80102072 <writei+0x3f>
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102066:	98                   	cwtl
80102067:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
      return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3b 01 00 00       	jmp    801021b7 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102083:	98                   	cwtl
80102084:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010208b:	8b 55 14             	mov    0x14(%ebp),%edx
8010208e:	83 ec 04             	sub    $0x4,%esp
80102091:	52                   	push   %edx
80102092:	ff 75 0c             	push   0xc(%ebp)
80102095:	ff 75 08             	push   0x8(%ebp)
80102098:	ff d0                	call   *%eax
8010209a:	83 c4 10             	add    $0x10,%esp
8010209d:	e9 15 01 00 00       	jmp    801021b7 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020a2:	8b 45 08             	mov    0x8(%ebp),%eax
801020a5:	8b 40 58             	mov    0x58(%eax),%eax
801020a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020ab:	72 0d                	jb     801020ba <writei+0x87>
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	8b 45 14             	mov    0x14(%ebp),%eax
801020b3:	01 d0                	add    %edx,%eax
801020b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b8:	73 0a                	jae    801020c4 <writei+0x91>
    return -1;
801020ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bf:	e9 f3 00 00 00       	jmp    801021b7 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ca:	01 d0                	add    %edx,%eax
801020cc:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d1:	76 0a                	jbe    801020dd <writei+0xaa>
    return -1;
801020d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d8:	e9 da 00 00 00       	jmp    801021b7 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e4:	e9 97 00 00 00       	jmp    80102180 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ec:	c1 e8 09             	shr    $0x9,%eax
801020ef:	83 ec 08             	sub    $0x8,%esp
801020f2:	50                   	push   %eax
801020f3:	ff 75 08             	push   0x8(%ebp)
801020f6:	e8 4d fb ff ff       	call   80101c48 <bmap>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102101:	8b 12                	mov    (%edx),%edx
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	52                   	push   %edx
80102108:	e8 f4 e0 ff ff       	call   80100201 <bread>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102113:	8b 45 10             	mov    0x10(%ebp),%eax
80102116:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211b:	ba 00 02 00 00       	mov    $0x200,%edx
80102120:	29 c2                	sub    %eax,%edx
80102122:	8b 45 14             	mov    0x14(%ebp),%eax
80102125:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102128:	39 c2                	cmp    %eax,%edx
8010212a:	0f 46 c2             	cmovbe %edx,%eax
8010212d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102133:	8d 50 5c             	lea    0x5c(%eax),%edx
80102136:	8b 45 10             	mov    0x10(%ebp),%eax
80102139:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213e:	01 d0                	add    %edx,%eax
80102140:	83 ec 04             	sub    $0x4,%esp
80102143:	ff 75 ec             	push   -0x14(%ebp)
80102146:	ff 75 0c             	push   0xc(%ebp)
80102149:	50                   	push   %eax
8010214a:	e8 0b 29 00 00       	call   80104a5a <memmove>
8010214f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	ff 75 f0             	push   -0x10(%ebp)
80102158:	e8 1a 11 00 00       	call   80103277 <log_write>
8010215d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102160:	83 ec 0c             	sub    $0xc,%esp
80102163:	ff 75 f0             	push   -0x10(%ebp)
80102166:	e8 18 e1 ff ff       	call   80100283 <brelse>
8010216b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102171:	01 45 f4             	add    %eax,-0xc(%ebp)
80102174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102177:	01 45 10             	add    %eax,0x10(%ebp)
8010217a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217d:	01 45 0c             	add    %eax,0xc(%ebp)
80102180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102183:	3b 45 14             	cmp    0x14(%ebp),%eax
80102186:	0f 82 5d ff ff ff    	jb     801020e9 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010218c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102190:	74 22                	je     801021b4 <writei+0x181>
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	8b 40 58             	mov    0x58(%eax),%eax
80102198:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219b:	73 17                	jae    801021b4 <writei+0x181>
    ip->size = off;
8010219d:	8b 45 08             	mov    0x8(%ebp),%eax
801021a0:	8b 55 10             	mov    0x10(%ebp),%edx
801021a3:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021a6:	83 ec 0c             	sub    $0xc,%esp
801021a9:	ff 75 08             	push   0x8(%ebp)
801021ac:	e8 64 f6 ff ff       	call   80101815 <iupdate>
801021b1:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b7:	c9                   	leave
801021b8:	c3                   	ret

801021b9 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b9:	55                   	push   %ebp
801021ba:	89 e5                	mov    %esp,%ebp
801021bc:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bf:	83 ec 04             	sub    $0x4,%esp
801021c2:	6a 0e                	push   $0xe
801021c4:	ff 75 0c             	push   0xc(%ebp)
801021c7:	ff 75 08             	push   0x8(%ebp)
801021ca:	e8 21 29 00 00       	call   80104af0 <strncmp>
801021cf:	83 c4 10             	add    $0x10,%esp
}
801021d2:	c9                   	leave
801021d3:	c3                   	ret

801021d4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d4:	55                   	push   %ebp
801021d5:	89 e5                	mov    %esp,%ebp
801021d7:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021e1:	66 83 f8 01          	cmp    $0x1,%ax
801021e5:	74 0d                	je     801021f4 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e7:	83 ec 0c             	sub    $0xc,%esp
801021ea:	68 dd a1 10 80       	push   $0x8010a1dd
801021ef:	e8 b5 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021fb:	eb 7b                	jmp    80102278 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fd:	6a 10                	push   $0x10
801021ff:	ff 75 f4             	push   -0xc(%ebp)
80102202:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102205:	50                   	push   %eax
80102206:	ff 75 08             	push   0x8(%ebp)
80102209:	e8 d0 fc ff ff       	call   80101ede <readi>
8010220e:	83 c4 10             	add    $0x10,%esp
80102211:	83 f8 10             	cmp    $0x10,%eax
80102214:	74 0d                	je     80102223 <dirlookup+0x4f>
      panic("dirlookup read");
80102216:	83 ec 0c             	sub    $0xc,%esp
80102219:	68 ef a1 10 80       	push   $0x8010a1ef
8010221e:	e8 86 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102223:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102227:	66 85 c0             	test   %ax,%ax
8010222a:	74 47                	je     80102273 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222c:	83 ec 08             	sub    $0x8,%esp
8010222f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102232:	83 c0 02             	add    $0x2,%eax
80102235:	50                   	push   %eax
80102236:	ff 75 0c             	push   0xc(%ebp)
80102239:	e8 7b ff ff ff       	call   801021b9 <namecmp>
8010223e:	83 c4 10             	add    $0x10,%esp
80102241:	85 c0                	test   %eax,%eax
80102243:	75 2f                	jne    80102274 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102249:	74 08                	je     80102253 <dirlookup+0x7f>
        *poff = off;
8010224b:	8b 45 10             	mov    0x10(%ebp),%eax
8010224e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102251:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102253:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102257:	0f b7 c0             	movzwl %ax,%eax
8010225a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	8b 00                	mov    (%eax),%eax
80102262:	83 ec 08             	sub    $0x8,%esp
80102265:	ff 75 f0             	push   -0x10(%ebp)
80102268:	50                   	push   %eax
80102269:	e8 68 f6 ff ff       	call   801018d6 <iget>
8010226e:	83 c4 10             	add    $0x10,%esp
80102271:	eb 19                	jmp    8010228c <dirlookup+0xb8>
      continue;
80102273:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102274:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 40 58             	mov    0x58(%eax),%eax
8010227e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102281:	0f 82 76 ff ff ff    	jb     801021fd <dirlookup+0x29>
    }
  }

  return 0;
80102287:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228c:	c9                   	leave
8010228d:	c3                   	ret

8010228e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228e:	55                   	push   %ebp
8010228f:	89 e5                	mov    %esp,%ebp
80102291:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102294:	83 ec 04             	sub    $0x4,%esp
80102297:	6a 00                	push   $0x0
80102299:	ff 75 0c             	push   0xc(%ebp)
8010229c:	ff 75 08             	push   0x8(%ebp)
8010229f:	e8 30 ff ff ff       	call   801021d4 <dirlookup>
801022a4:	83 c4 10             	add    $0x10,%esp
801022a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ae:	74 18                	je     801022c8 <dirlink+0x3a>
    iput(ip);
801022b0:	83 ec 0c             	sub    $0xc,%esp
801022b3:	ff 75 f0             	push   -0x10(%ebp)
801022b6:	e8 98 f8 ff ff       	call   80101b53 <iput>
801022bb:	83 c4 10             	add    $0x10,%esp
    return -1;
801022be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c3:	e9 9c 00 00 00       	jmp    80102364 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cf:	eb 39                	jmp    8010230a <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d4:	6a 10                	push   $0x10
801022d6:	50                   	push   %eax
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	50                   	push   %eax
801022db:	ff 75 08             	push   0x8(%ebp)
801022de:	e8 fb fb ff ff       	call   80101ede <readi>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	83 f8 10             	cmp    $0x10,%eax
801022e9:	74 0d                	je     801022f8 <dirlink+0x6a>
      panic("dirlink read");
801022eb:	83 ec 0c             	sub    $0xc,%esp
801022ee:	68 fe a1 10 80       	push   $0x8010a1fe
801022f3:	e8 b1 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fc:	66 85 c0             	test   %ax,%ax
801022ff:	74 18                	je     80102319 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102304:	83 c0 10             	add    $0x10,%eax
80102307:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 58             	mov    0x58(%eax),%eax
80102310:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102313:	39 c2                	cmp    %eax,%edx
80102315:	72 ba                	jb     801022d1 <dirlink+0x43>
80102317:	eb 01                	jmp    8010231a <dirlink+0x8c>
      break;
80102319:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010231a:	83 ec 04             	sub    $0x4,%esp
8010231d:	6a 0e                	push   $0xe
8010231f:	ff 75 0c             	push   0xc(%ebp)
80102322:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102325:	83 c0 02             	add    $0x2,%eax
80102328:	50                   	push   %eax
80102329:	e8 18 28 00 00       	call   80104b46 <strncpy>
8010232e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	6a 10                	push   $0x10
8010233d:	50                   	push   %eax
8010233e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102341:	50                   	push   %eax
80102342:	ff 75 08             	push   0x8(%ebp)
80102345:	e8 e9 fc ff ff       	call   80102033 <writei>
8010234a:	83 c4 10             	add    $0x10,%esp
8010234d:	83 f8 10             	cmp    $0x10,%eax
80102350:	74 0d                	je     8010235f <dirlink+0xd1>
    panic("dirlink");
80102352:	83 ec 0c             	sub    $0xc,%esp
80102355:	68 0b a2 10 80       	push   $0x8010a20b
8010235a:	e8 4a e2 ff ff       	call   801005a9 <panic>

  return 0;
8010235f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102364:	c9                   	leave
80102365:	c3                   	ret

80102366 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102366:	55                   	push   %ebp
80102367:	89 e5                	mov    %esp,%ebp
80102369:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236c:	eb 04                	jmp    80102372 <skipelem+0xc>
    path++;
8010236e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	0f b6 00             	movzbl (%eax),%eax
80102378:	3c 2f                	cmp    $0x2f,%al
8010237a:	74 f2                	je     8010236e <skipelem+0x8>
  if(*path == 0)
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b6 00             	movzbl (%eax),%eax
80102382:	84 c0                	test   %al,%al
80102384:	75 07                	jne    8010238d <skipelem+0x27>
    return 0;
80102386:	b8 00 00 00 00       	mov    $0x0,%eax
8010238b:	eb 77                	jmp    80102404 <skipelem+0x9e>
  s = path;
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102393:	eb 04                	jmp    80102399 <skipelem+0x33>
    path++;
80102395:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b6 00             	movzbl (%eax),%eax
8010239f:	3c 2f                	cmp    $0x2f,%al
801023a1:	74 0a                	je     801023ad <skipelem+0x47>
801023a3:	8b 45 08             	mov    0x8(%ebp),%eax
801023a6:	0f b6 00             	movzbl (%eax),%eax
801023a9:	84 c0                	test   %al,%al
801023ab:	75 e8                	jne    80102395 <skipelem+0x2f>
  len = path - s;
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ba:	7e 15                	jle    801023d1 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023bc:	83 ec 04             	sub    $0x4,%esp
801023bf:	6a 0e                	push   $0xe
801023c1:	ff 75 f4             	push   -0xc(%ebp)
801023c4:	ff 75 0c             	push   0xc(%ebp)
801023c7:	e8 8e 26 00 00       	call   80104a5a <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 77 26 00 00       	call   80104a5a <memmove>
801023e3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ec:	01 d0                	add    %edx,%eax
801023ee:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f1:	eb 04                	jmp    801023f7 <skipelem+0x91>
    path++;
801023f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	3c 2f                	cmp    $0x2f,%al
801023ff:	74 f2                	je     801023f3 <skipelem+0x8d>
  return path;
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102404:	c9                   	leave
80102405:	c3                   	ret

80102406 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	3c 2f                	cmp    $0x2f,%al
80102414:	75 17                	jne    8010242d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102416:	83 ec 08             	sub    $0x8,%esp
80102419:	6a 01                	push   $0x1
8010241b:	6a 01                	push   $0x1
8010241d:	e8 b4 f4 ff ff       	call   801018d6 <iget>
80102422:	83 c4 10             	add    $0x10,%esp
80102425:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102428:	e9 ba 00 00 00       	jmp    801024e7 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010242d:	e8 fe 15 00 00       	call   80103a30 <myproc>
80102432:	8b 40 68             	mov    0x68(%eax),%eax
80102435:	83 ec 0c             	sub    $0xc,%esp
80102438:	50                   	push   %eax
80102439:	e8 7a f5 ff ff       	call   801019b8 <idup>
8010243e:	83 c4 10             	add    $0x10,%esp
80102441:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102444:	e9 9e 00 00 00       	jmp    801024e7 <namex+0xe1>
    ilock(ip);
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	ff 75 f4             	push   -0xc(%ebp)
8010244f:	e8 9e f5 ff ff       	call   801019f2 <ilock>
80102454:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010245e:	66 83 f8 01          	cmp    $0x1,%ax
80102462:	74 18                	je     8010247c <namex+0x76>
      iunlockput(ip);
80102464:	83 ec 0c             	sub    $0xc,%esp
80102467:	ff 75 f4             	push   -0xc(%ebp)
8010246a:	e8 b4 f7 ff ff       	call   80101c23 <iunlockput>
8010246f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102472:	b8 00 00 00 00       	mov    $0x0,%eax
80102477:	e9 a7 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010247c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102480:	74 20                	je     801024a2 <namex+0x9c>
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	0f b6 00             	movzbl (%eax),%eax
80102488:	84 c0                	test   %al,%al
8010248a:	75 16                	jne    801024a2 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010248c:	83 ec 0c             	sub    $0xc,%esp
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 6e f6 ff ff       	call   80101b05 <iunlock>
80102497:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249d:	e9 81 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	6a 00                	push   $0x0
801024a7:	ff 75 10             	push   0x10(%ebp)
801024aa:	ff 75 f4             	push   -0xc(%ebp)
801024ad:	e8 22 fd ff ff       	call   801021d4 <dirlookup>
801024b2:	83 c4 10             	add    $0x10,%esp
801024b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bc:	75 15                	jne    801024d3 <namex+0xcd>
      iunlockput(ip);
801024be:	83 ec 0c             	sub    $0xc,%esp
801024c1:	ff 75 f4             	push   -0xc(%ebp)
801024c4:	e8 5a f7 ff ff       	call   80101c23 <iunlockput>
801024c9:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cc:	b8 00 00 00 00       	mov    $0x0,%eax
801024d1:	eb 50                	jmp    80102523 <namex+0x11d>
    }
    iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 45 f7 ff ff       	call   80101c23 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e7:	83 ec 08             	sub    $0x8,%esp
801024ea:	ff 75 10             	push   0x10(%ebp)
801024ed:	ff 75 08             	push   0x8(%ebp)
801024f0:	e8 71 fe ff ff       	call   80102366 <skipelem>
801024f5:	83 c4 10             	add    $0x10,%esp
801024f8:	89 45 08             	mov    %eax,0x8(%ebp)
801024fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ff:	0f 85 44 ff ff ff    	jne    80102449 <namex+0x43>
  }
  if(nameiparent){
80102505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102509:	74 15                	je     80102520 <namex+0x11a>
    iput(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	push   -0xc(%ebp)
80102511:	e8 3d f6 ff ff       	call   80101b53 <iput>
80102516:	83 c4 10             	add    $0x10,%esp
    return 0;
80102519:	b8 00 00 00 00       	mov    $0x0,%eax
8010251e:	eb 03                	jmp    80102523 <namex+0x11d>
  }
  return ip;
80102520:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102523:	c9                   	leave
80102524:	c3                   	ret

80102525 <namei>:

struct inode*
namei(char *path)
{
80102525:	55                   	push   %ebp
80102526:	89 e5                	mov    %esp,%ebp
80102528:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252b:	83 ec 04             	sub    $0x4,%esp
8010252e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102531:	50                   	push   %eax
80102532:	6a 00                	push   $0x0
80102534:	ff 75 08             	push   0x8(%ebp)
80102537:	e8 ca fe ff ff       	call   80102406 <namex>
8010253c:	83 c4 10             	add    $0x10,%esp
}
8010253f:	c9                   	leave
80102540:	c3                   	ret

80102541 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102541:	55                   	push   %ebp
80102542:	89 e5                	mov    %esp,%ebp
80102544:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102547:	83 ec 04             	sub    $0x4,%esp
8010254a:	ff 75 0c             	push   0xc(%ebp)
8010254d:	6a 01                	push   $0x1
8010254f:	ff 75 08             	push   0x8(%ebp)
80102552:	e8 af fe ff ff       	call   80102406 <namex>
80102557:	83 c4 10             	add    $0x10,%esp
}
8010255a:	c9                   	leave
8010255b:	c3                   	ret

8010255c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010255f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102564:	8b 55 08             	mov    0x8(%ebp),%edx
80102567:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102569:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102571:	5d                   	pop    %ebp
80102572:	c3                   	ret

80102573 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102573:	55                   	push   %ebp
80102574:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102576:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257b:	8b 55 08             	mov    0x8(%ebp),%edx
8010257e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102580:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102585:	8b 55 0c             	mov    0xc(%ebp),%edx
80102588:	89 50 10             	mov    %edx,0x10(%eax)
}
8010258b:	90                   	nop
8010258c:	5d                   	pop    %ebp
8010258d:	c3                   	ret

8010258e <ioapicinit>:

void
ioapicinit(void)
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102594:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
8010259b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010259e:	6a 01                	push   $0x1
801025a0:	e8 b7 ff ff ff       	call   8010255c <ioapicread>
801025a5:	83 c4 04             	add    $0x4,%esp
801025a8:	c1 e8 10             	shr    $0x10,%eax
801025ab:	25 ff 00 00 00       	and    $0xff,%eax
801025b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025b3:	6a 00                	push   $0x0
801025b5:	e8 a2 ff ff ff       	call   8010255c <ioapicread>
801025ba:	83 c4 04             	add    $0x4,%esp
801025bd:	c1 e8 18             	shr    $0x18,%eax
801025c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025c3:	0f b6 05 44 6d 19 80 	movzbl 0x80196d44,%eax
801025ca:	0f b6 c0             	movzbl %al,%eax
801025cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d0:	74 10                	je     801025e2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	68 14 a2 10 80       	push   $0x8010a214
801025da:	e8 15 de ff ff       	call   801003f4 <cprintf>
801025df:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e9:	eb 3f                	jmp    8010262a <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	83 c0 20             	add    $0x20,%eax
801025f1:	0d 00 00 01 00       	or     $0x10000,%eax
801025f6:	89 c2                	mov    %eax,%edx
801025f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fb:	83 c0 08             	add    $0x8,%eax
801025fe:	01 c0                	add    %eax,%eax
80102600:	83 ec 08             	sub    $0x8,%esp
80102603:	52                   	push   %edx
80102604:	50                   	push   %eax
80102605:	e8 69 ff ff ff       	call   80102573 <ioapicwrite>
8010260a:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102610:	83 c0 08             	add    $0x8,%eax
80102613:	01 c0                	add    %eax,%eax
80102615:	83 c0 01             	add    $0x1,%eax
80102618:	83 ec 08             	sub    $0x8,%esp
8010261b:	6a 00                	push   $0x0
8010261d:	50                   	push   %eax
8010261e:	e8 50 ff ff ff       	call   80102573 <ioapicwrite>
80102623:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102626:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010262a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102630:	7e b9                	jle    801025eb <ioapicinit+0x5d>
  }
}
80102632:	90                   	nop
80102633:	90                   	nop
80102634:	c9                   	leave
80102635:	c3                   	ret

80102636 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102636:	55                   	push   %ebp
80102637:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 20             	add    $0x20,%eax
8010263f:	89 c2                	mov    %eax,%edx
80102641:	8b 45 08             	mov    0x8(%ebp),%eax
80102644:	83 c0 08             	add    $0x8,%eax
80102647:	01 c0                	add    %eax,%eax
80102649:	52                   	push   %edx
8010264a:	50                   	push   %eax
8010264b:	e8 23 ff ff ff       	call   80102573 <ioapicwrite>
80102650:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102653:	8b 45 0c             	mov    0xc(%ebp),%eax
80102656:	c1 e0 18             	shl    $0x18,%eax
80102659:	89 c2                	mov    %eax,%edx
8010265b:	8b 45 08             	mov    0x8(%ebp),%eax
8010265e:	83 c0 08             	add    $0x8,%eax
80102661:	01 c0                	add    %eax,%eax
80102663:	83 c0 01             	add    $0x1,%eax
80102666:	52                   	push   %edx
80102667:	50                   	push   %eax
80102668:	e8 06 ff ff ff       	call   80102573 <ioapicwrite>
8010266d:	83 c4 08             	add    $0x8,%esp
}
80102670:	90                   	nop
80102671:	c9                   	leave
80102672:	c3                   	ret

80102673 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102673:	55                   	push   %ebp
80102674:	89 e5                	mov    %esp,%ebp
80102676:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102679:	83 ec 08             	sub    $0x8,%esp
8010267c:	68 46 a2 10 80       	push   $0x8010a246
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 78 20 00 00       	call   80104703 <initlock>
8010268b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010268e:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
80102695:	00 00 00 
  freerange(vstart, vend);
80102698:	83 ec 08             	sub    $0x8,%esp
8010269b:	ff 75 0c             	push   0xc(%ebp)
8010269e:	ff 75 08             	push   0x8(%ebp)
801026a1:	e8 2a 00 00 00       	call   801026d0 <freerange>
801026a6:	83 c4 10             	add    $0x10,%esp
}
801026a9:	90                   	nop
801026aa:	c9                   	leave
801026ab:	c3                   	ret

801026ac <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026ac:	55                   	push   %ebp
801026ad:	89 e5                	mov    %esp,%ebp
801026af:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026b2:	83 ec 08             	sub    $0x8,%esp
801026b5:	ff 75 0c             	push   0xc(%ebp)
801026b8:	ff 75 08             	push   0x8(%ebp)
801026bb:	e8 10 00 00 00       	call   801026d0 <freerange>
801026c0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026c3:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026ca:	00 00 00 
}
801026cd:	90                   	nop
801026ce:	c9                   	leave
801026cf:	c3                   	ret

801026d0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026d6:	8b 45 08             	mov    0x8(%ebp),%eax
801026d9:	05 ff 0f 00 00       	add    $0xfff,%eax
801026de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e6:	eb 15                	jmp    801026fd <freerange+0x2d>
    kfree(p);
801026e8:	83 ec 0c             	sub    $0xc,%esp
801026eb:	ff 75 f4             	push   -0xc(%ebp)
801026ee:	e8 1b 00 00 00       	call   8010270e <kfree>
801026f3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026f6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102700:	05 00 10 00 00       	add    $0x1000,%eax
80102705:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102708:	73 de                	jae    801026e8 <freerange+0x18>
}
8010270a:	90                   	nop
8010270b:	90                   	nop
8010270c:	c9                   	leave
8010270d:	c3                   	ret

8010270e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010270e:	55                   	push   %ebp
8010270f:	89 e5                	mov    %esp,%ebp
80102711:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	25 ff 0f 00 00       	and    $0xfff,%eax
8010271c:	85 c0                	test   %eax,%eax
8010271e:	75 18                	jne    80102738 <kfree+0x2a>
80102720:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102727:	72 0f                	jb     80102738 <kfree+0x2a>
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	05 00 00 00 80       	add    $0x80000000,%eax
80102731:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102736:	76 0d                	jbe    80102745 <kfree+0x37>
    panic("kfree");
80102738:	83 ec 0c             	sub    $0xc,%esp
8010273b:	68 4b a2 10 80       	push   $0x8010a24b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 44 22 00 00       	call   8010499b <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 b5 1f 00 00       	call   80104725 <acquire>
80102770:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102779:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
8010277f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102782:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102787:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
8010278c:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102791:	85 c0                	test   %eax,%eax
80102793:	74 10                	je     801027a5 <kfree+0x97>
    release(&kmem.lock);
80102795:	83 ec 0c             	sub    $0xc,%esp
80102798:	68 c0 40 19 80       	push   $0x801940c0
8010279d:	e8 f1 1f 00 00       	call   80104793 <release>
801027a2:	83 c4 10             	add    $0x10,%esp
}
801027a5:	90                   	nop
801027a6:	c9                   	leave
801027a7:	c3                   	ret

801027a8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a8:	55                   	push   %ebp
801027a9:	89 e5                	mov    %esp,%ebp
801027ab:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027ae:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027b3:	85 c0                	test   %eax,%eax
801027b5:	74 10                	je     801027c7 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b7:	83 ec 0c             	sub    $0xc,%esp
801027ba:	68 c0 40 19 80       	push   $0x801940c0
801027bf:	e8 61 1f 00 00       	call   80104725 <acquire>
801027c4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c7:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d3:	74 0a                	je     801027df <kalloc+0x37>
    kmem.freelist = r->next;
801027d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d8:	8b 00                	mov    (%eax),%eax
801027da:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027df:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027e4:	85 c0                	test   %eax,%eax
801027e6:	74 10                	je     801027f8 <kalloc+0x50>
    release(&kmem.lock);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	68 c0 40 19 80       	push   $0x801940c0
801027f0:	e8 9e 1f 00 00       	call   80104793 <release>
801027f5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027fb:	c9                   	leave
801027fc:	c3                   	ret

801027fd <inb>:
{
801027fd:	55                   	push   %ebp
801027fe:	89 e5                	mov    %esp,%ebp
80102800:	83 ec 14             	sub    $0x14,%esp
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010280a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010280e:	89 c2                	mov    %eax,%edx
80102810:	ec                   	in     (%dx),%al
80102811:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102814:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102818:	c9                   	leave
80102819:	c3                   	ret

8010281a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010281a:	55                   	push   %ebp
8010281b:	89 e5                	mov    %esp,%ebp
8010281d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102820:	6a 64                	push   $0x64
80102822:	e8 d6 ff ff ff       	call   801027fd <inb>
80102827:	83 c4 04             	add    $0x4,%esp
8010282a:	0f b6 c0             	movzbl %al,%eax
8010282d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102833:	83 e0 01             	and    $0x1,%eax
80102836:	85 c0                	test   %eax,%eax
80102838:	75 0a                	jne    80102844 <kbdgetc+0x2a>
    return -1;
8010283a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010283f:	e9 23 01 00 00       	jmp    80102967 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102844:	6a 60                	push   $0x60
80102846:	e8 b2 ff ff ff       	call   801027fd <inb>
8010284b:	83 c4 04             	add    $0x4,%esp
8010284e:	0f b6 c0             	movzbl %al,%eax
80102851:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102854:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010285b:	75 17                	jne    80102874 <kbdgetc+0x5a>
    shift |= E0ESC;
8010285d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102862:	83 c8 40             	or     $0x40,%eax
80102865:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
8010286a:	b8 00 00 00 00       	mov    $0x0,%eax
8010286f:	e9 f3 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102877:	25 80 00 00 00       	and    $0x80,%eax
8010287c:	85 c0                	test   %eax,%eax
8010287e:	74 45                	je     801028c5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102880:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102885:	83 e0 40             	and    $0x40,%eax
80102888:	85 c0                	test   %eax,%eax
8010288a:	75 08                	jne    80102894 <kbdgetc+0x7a>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	83 e0 7f             	and    $0x7f,%eax
80102892:	eb 03                	jmp    80102897 <kbdgetc+0x7d>
80102894:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102897:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010289a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010289d:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028a2:	0f b6 00             	movzbl (%eax),%eax
801028a5:	83 c8 40             	or     $0x40,%eax
801028a8:	0f b6 c0             	movzbl %al,%eax
801028ab:	f7 d0                	not    %eax
801028ad:	89 c2                	mov    %eax,%edx
801028af:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028b4:	21 d0                	and    %edx,%eax
801028b6:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028bb:	b8 00 00 00 00       	mov    $0x0,%eax
801028c0:	e9 a2 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028c5:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ca:	83 e0 40             	and    $0x40,%eax
801028cd:	85 c0                	test   %eax,%eax
801028cf:	74 14                	je     801028e5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028d1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028dd:	83 e0 bf             	and    $0xffffffbf,%eax
801028e0:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e8:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028ed:	0f b6 00             	movzbl (%eax),%eax
801028f0:	0f b6 d0             	movzbl %al,%edx
801028f3:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f8:	09 d0                	or     %edx,%eax
801028fa:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102902:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102907:	0f b6 00             	movzbl (%eax),%eax
8010290a:	0f b6 d0             	movzbl %al,%edx
8010290d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102912:	31 d0                	xor    %edx,%eax
80102914:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102919:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010291e:	83 e0 03             	and    $0x3,%eax
80102921:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102928:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010292b:	01 d0                	add    %edx,%eax
8010292d:	0f b6 00             	movzbl (%eax),%eax
80102930:	0f b6 c0             	movzbl %al,%eax
80102933:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102936:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010293b:	83 e0 08             	and    $0x8,%eax
8010293e:	85 c0                	test   %eax,%eax
80102940:	74 22                	je     80102964 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102942:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102946:	76 0c                	jbe    80102954 <kbdgetc+0x13a>
80102948:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010294c:	77 06                	ja     80102954 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010294e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102952:	eb 10                	jmp    80102964 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102954:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102958:	76 0a                	jbe    80102964 <kbdgetc+0x14a>
8010295a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010295e:	77 04                	ja     80102964 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102960:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102964:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102967:	c9                   	leave
80102968:	c3                   	ret

80102969 <kbdintr>:

void
kbdintr(void)
{
80102969:	55                   	push   %ebp
8010296a:	89 e5                	mov    %esp,%ebp
8010296c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010296f:	83 ec 0c             	sub    $0xc,%esp
80102972:	68 1a 28 10 80       	push   $0x8010281a
80102977:	e8 5a de ff ff       	call   801007d6 <consoleintr>
8010297c:	83 c4 10             	add    $0x10,%esp
}
8010297f:	90                   	nop
80102980:	c9                   	leave
80102981:	c3                   	ret

80102982 <inb>:
{
80102982:	55                   	push   %ebp
80102983:	89 e5                	mov    %esp,%ebp
80102985:	83 ec 14             	sub    $0x14,%esp
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010298f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102993:	89 c2                	mov    %eax,%edx
80102995:	ec                   	in     (%dx),%al
80102996:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102999:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010299d:	c9                   	leave
8010299e:	c3                   	ret

8010299f <outb>:
{
8010299f:	55                   	push   %ebp
801029a0:	89 e5                	mov    %esp,%ebp
801029a2:	83 ec 08             	sub    $0x8,%esp
801029a5:	8b 55 08             	mov    0x8(%ebp),%edx
801029a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801029af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029ba:	ee                   	out    %al,(%dx)
}
801029bb:	90                   	nop
801029bc:	c9                   	leave
801029bd:	c3                   	ret

801029be <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029be:	55                   	push   %ebp
801029bf:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029c1:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c6:	8b 55 08             	mov    0x8(%ebp),%edx
801029c9:	c1 e2 02             	shl    $0x2,%edx
801029cc:	01 c2                	add    %eax,%edx
801029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801029d1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029d3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d8:	83 c0 20             	add    $0x20,%eax
801029db:	8b 00                	mov    (%eax),%eax
}
801029dd:	90                   	nop
801029de:	5d                   	pop    %ebp
801029df:	c3                   	ret

801029e0 <lapicinit>:

void
lapicinit(void)
{
801029e0:	55                   	push   %ebp
801029e1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029e3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e8:	85 c0                	test   %eax,%eax
801029ea:	0f 84 09 01 00 00    	je     80102af9 <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029f0:	68 3f 01 00 00       	push   $0x13f
801029f5:	6a 3c                	push   $0x3c
801029f7:	e8 c2 ff ff ff       	call   801029be <lapicw>
801029fc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029ff:	6a 0b                	push   $0xb
80102a01:	68 f8 00 00 00       	push   $0xf8
80102a06:	e8 b3 ff ff ff       	call   801029be <lapicw>
80102a0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a0e:	68 20 00 02 00       	push   $0x20020
80102a13:	68 c8 00 00 00       	push   $0xc8
80102a18:	e8 a1 ff ff ff       	call   801029be <lapicw>
80102a1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a20:	68 80 96 98 00       	push   $0x989680
80102a25:	68 e0 00 00 00       	push   $0xe0
80102a2a:	e8 8f ff ff ff       	call   801029be <lapicw>
80102a2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a32:	68 00 00 01 00       	push   $0x10000
80102a37:	68 d4 00 00 00       	push   $0xd4
80102a3c:	e8 7d ff ff ff       	call   801029be <lapicw>
80102a41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a44:	68 00 00 01 00       	push   $0x10000
80102a49:	68 d8 00 00 00       	push   $0xd8
80102a4e:	e8 6b ff ff ff       	call   801029be <lapicw>
80102a53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a56:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a5b:	83 c0 30             	add    $0x30,%eax
80102a5e:	8b 00                	mov    (%eax),%eax
80102a60:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102a65:	85 c0                	test   %eax,%eax
80102a67:	74 12                	je     80102a7b <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102a69:	68 00 00 01 00       	push   $0x10000
80102a6e:	68 d0 00 00 00       	push   $0xd0
80102a73:	e8 46 ff ff ff       	call   801029be <lapicw>
80102a78:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a7b:	6a 33                	push   $0x33
80102a7d:	68 dc 00 00 00       	push   $0xdc
80102a82:	e8 37 ff ff ff       	call   801029be <lapicw>
80102a87:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a8a:	6a 00                	push   $0x0
80102a8c:	68 a0 00 00 00       	push   $0xa0
80102a91:	e8 28 ff ff ff       	call   801029be <lapicw>
80102a96:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a99:	6a 00                	push   $0x0
80102a9b:	68 a0 00 00 00       	push   $0xa0
80102aa0:	e8 19 ff ff ff       	call   801029be <lapicw>
80102aa5:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa8:	6a 00                	push   $0x0
80102aaa:	6a 2c                	push   $0x2c
80102aac:	e8 0d ff ff ff       	call   801029be <lapicw>
80102ab1:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab4:	6a 00                	push   $0x0
80102ab6:	68 c4 00 00 00       	push   $0xc4
80102abb:	e8 fe fe ff ff       	call   801029be <lapicw>
80102ac0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac3:	68 00 85 08 00       	push   $0x88500
80102ac8:	68 c0 00 00 00       	push   $0xc0
80102acd:	e8 ec fe ff ff       	call   801029be <lapicw>
80102ad2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad5:	90                   	nop
80102ad6:	a1 00 41 19 80       	mov    0x80194100,%eax
80102adb:	05 00 03 00 00       	add    $0x300,%eax
80102ae0:	8b 00                	mov    (%eax),%eax
80102ae2:	25 00 10 00 00       	and    $0x1000,%eax
80102ae7:	85 c0                	test   %eax,%eax
80102ae9:	75 eb                	jne    80102ad6 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102aeb:	6a 00                	push   $0x0
80102aed:	6a 20                	push   $0x20
80102aef:	e8 ca fe ff ff       	call   801029be <lapicw>
80102af4:	83 c4 08             	add    $0x8,%esp
80102af7:	eb 01                	jmp    80102afa <lapicinit+0x11a>
    return;
80102af9:	90                   	nop
}
80102afa:	c9                   	leave
80102afb:	c3                   	ret

80102afc <lapicid>:

int
lapicid(void)
{
80102afc:	55                   	push   %ebp
80102afd:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102aff:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b04:	85 c0                	test   %eax,%eax
80102b06:	75 07                	jne    80102b0f <lapicid+0x13>
    return 0;
80102b08:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0d:	eb 0d                	jmp    80102b1c <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b14:	83 c0 20             	add    $0x20,%eax
80102b17:	8b 00                	mov    (%eax),%eax
80102b19:	c1 e8 18             	shr    $0x18,%eax
}
80102b1c:	5d                   	pop    %ebp
80102b1d:	c3                   	ret

80102b1e <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1e:	55                   	push   %ebp
80102b1f:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b21:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b26:	85 c0                	test   %eax,%eax
80102b28:	74 0c                	je     80102b36 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b2a:	6a 00                	push   $0x0
80102b2c:	6a 2c                	push   $0x2c
80102b2e:	e8 8b fe ff ff       	call   801029be <lapicw>
80102b33:	83 c4 08             	add    $0x8,%esp
}
80102b36:	90                   	nop
80102b37:	c9                   	leave
80102b38:	c3                   	ret

80102b39 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b39:	55                   	push   %ebp
80102b3a:	89 e5                	mov    %esp,%ebp
}
80102b3c:	90                   	nop
80102b3d:	5d                   	pop    %ebp
80102b3e:	c3                   	ret

80102b3f <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3f:	55                   	push   %ebp
80102b40:	89 e5                	mov    %esp,%ebp
80102b42:	83 ec 14             	sub    $0x14,%esp
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b4b:	6a 0f                	push   $0xf
80102b4d:	6a 70                	push   $0x70
80102b4f:	e8 4b fe ff ff       	call   8010299f <outb>
80102b54:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b57:	6a 0a                	push   $0xa
80102b59:	6a 71                	push   $0x71
80102b5b:	e8 3f fe ff ff       	call   8010299f <outb>
80102b60:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b63:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b72:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b75:	c1 e8 04             	shr    $0x4,%eax
80102b78:	89 c2                	mov    %eax,%edx
80102b7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7d:	83 c0 02             	add    $0x2,%eax
80102b80:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b83:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b87:	c1 e0 18             	shl    $0x18,%eax
80102b8a:	50                   	push   %eax
80102b8b:	68 c4 00 00 00       	push   $0xc4
80102b90:	e8 29 fe ff ff       	call   801029be <lapicw>
80102b95:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b98:	68 00 c5 00 00       	push   $0xc500
80102b9d:	68 c0 00 00 00       	push   $0xc0
80102ba2:	e8 17 fe ff ff       	call   801029be <lapicw>
80102ba7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102baa:	68 c8 00 00 00       	push   $0xc8
80102baf:	e8 85 ff ff ff       	call   80102b39 <microdelay>
80102bb4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb7:	68 00 85 00 00       	push   $0x8500
80102bbc:	68 c0 00 00 00       	push   $0xc0
80102bc1:	e8 f8 fd ff ff       	call   801029be <lapicw>
80102bc6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc9:	6a 64                	push   $0x64
80102bcb:	e8 69 ff ff ff       	call   80102b39 <microdelay>
80102bd0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bda:	eb 3d                	jmp    80102c19 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bdc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102be0:	c1 e0 18             	shl    $0x18,%eax
80102be3:	50                   	push   %eax
80102be4:	68 c4 00 00 00       	push   $0xc4
80102be9:	e8 d0 fd ff ff       	call   801029be <lapicw>
80102bee:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf4:	c1 e8 0c             	shr    $0xc,%eax
80102bf7:	80 cc 06             	or     $0x6,%ah
80102bfa:	50                   	push   %eax
80102bfb:	68 c0 00 00 00       	push   $0xc0
80102c00:	e8 b9 fd ff ff       	call   801029be <lapicw>
80102c05:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c08:	68 c8 00 00 00       	push   $0xc8
80102c0d:	e8 27 ff ff ff       	call   80102b39 <microdelay>
80102c12:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c15:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c19:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1d:	7e bd                	jle    80102bdc <lapicstartap+0x9d>
  }
}
80102c1f:	90                   	nop
80102c20:	90                   	nop
80102c21:	c9                   	leave
80102c22:	c3                   	ret

80102c23 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c26:	8b 45 08             	mov    0x8(%ebp),%eax
80102c29:	0f b6 c0             	movzbl %al,%eax
80102c2c:	50                   	push   %eax
80102c2d:	6a 70                	push   $0x70
80102c2f:	e8 6b fd ff ff       	call   8010299f <outb>
80102c34:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c37:	68 c8 00 00 00       	push   $0xc8
80102c3c:	e8 f8 fe ff ff       	call   80102b39 <microdelay>
80102c41:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c44:	6a 71                	push   $0x71
80102c46:	e8 37 fd ff ff       	call   80102982 <inb>
80102c4b:	83 c4 04             	add    $0x4,%esp
80102c4e:	0f b6 c0             	movzbl %al,%eax
}
80102c51:	c9                   	leave
80102c52:	c3                   	ret

80102c53 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c53:	55                   	push   %ebp
80102c54:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c56:	6a 00                	push   $0x0
80102c58:	e8 c6 ff ff ff       	call   80102c23 <cmos_read>
80102c5d:	83 c4 04             	add    $0x4,%esp
80102c60:	8b 55 08             	mov    0x8(%ebp),%edx
80102c63:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c65:	6a 02                	push   $0x2
80102c67:	e8 b7 ff ff ff       	call   80102c23 <cmos_read>
80102c6c:	83 c4 04             	add    $0x4,%esp
80102c6f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c72:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c75:	6a 04                	push   $0x4
80102c77:	e8 a7 ff ff ff       	call   80102c23 <cmos_read>
80102c7c:	83 c4 04             	add    $0x4,%esp
80102c7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c82:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c85:	6a 07                	push   $0x7
80102c87:	e8 97 ff ff ff       	call   80102c23 <cmos_read>
80102c8c:	83 c4 04             	add    $0x4,%esp
80102c8f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c92:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c95:	6a 08                	push   $0x8
80102c97:	e8 87 ff ff ff       	call   80102c23 <cmos_read>
80102c9c:	83 c4 04             	add    $0x4,%esp
80102c9f:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca2:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca5:	6a 09                	push   $0x9
80102ca7:	e8 77 ff ff ff       	call   80102c23 <cmos_read>
80102cac:	83 c4 04             	add    $0x4,%esp
80102caf:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb2:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb5:	90                   	nop
80102cb6:	c9                   	leave
80102cb7:	c3                   	ret

80102cb8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbe:	6a 0b                	push   $0xb
80102cc0:	e8 5e ff ff ff       	call   80102c23 <cmos_read>
80102cc5:	83 c4 04             	add    $0x4,%esp
80102cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cce:	83 e0 04             	and    $0x4,%eax
80102cd1:	85 c0                	test   %eax,%eax
80102cd3:	0f 94 c0             	sete   %al
80102cd6:	0f b6 c0             	movzbl %al,%eax
80102cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cdc:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdf:	50                   	push   %eax
80102ce0:	e8 6e ff ff ff       	call   80102c53 <fill_rtcdate>
80102ce5:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce8:	6a 0a                	push   $0xa
80102cea:	e8 34 ff ff ff       	call   80102c23 <cmos_read>
80102cef:	83 c4 04             	add    $0x4,%esp
80102cf2:	25 80 00 00 00       	and    $0x80,%eax
80102cf7:	85 c0                	test   %eax,%eax
80102cf9:	75 27                	jne    80102d22 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cfb:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfe:	50                   	push   %eax
80102cff:	e8 4f ff ff ff       	call   80102c53 <fill_rtcdate>
80102d04:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d07:	83 ec 04             	sub    $0x4,%esp
80102d0a:	6a 18                	push   $0x18
80102d0c:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0f:	50                   	push   %eax
80102d10:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d13:	50                   	push   %eax
80102d14:	e8 e9 1c 00 00       	call   80104a02 <memcmp>
80102d19:	83 c4 10             	add    $0x10,%esp
80102d1c:	85 c0                	test   %eax,%eax
80102d1e:	74 05                	je     80102d25 <cmostime+0x6d>
80102d20:	eb ba                	jmp    80102cdc <cmostime+0x24>
        continue;
80102d22:	90                   	nop
    fill_rtcdate(&t1);
80102d23:	eb b7                	jmp    80102cdc <cmostime+0x24>
      break;
80102d25:	90                   	nop
  }

  // convert
  if(bcd) {
80102d26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d2a:	0f 84 b4 00 00 00    	je     80102de4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d30:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d33:	c1 e8 04             	shr    $0x4,%eax
80102d36:	89 c2                	mov    %eax,%edx
80102d38:	89 d0                	mov    %edx,%eax
80102d3a:	c1 e0 02             	shl    $0x2,%eax
80102d3d:	01 d0                	add    %edx,%eax
80102d3f:	01 c0                	add    %eax,%eax
80102d41:	89 c2                	mov    %eax,%edx
80102d43:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d46:	83 e0 0f             	and    $0xf,%eax
80102d49:	01 d0                	add    %edx,%eax
80102d4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d51:	c1 e8 04             	shr    $0x4,%eax
80102d54:	89 c2                	mov    %eax,%edx
80102d56:	89 d0                	mov    %edx,%eax
80102d58:	c1 e0 02             	shl    $0x2,%eax
80102d5b:	01 d0                	add    %edx,%eax
80102d5d:	01 c0                	add    %eax,%eax
80102d5f:	89 c2                	mov    %eax,%edx
80102d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d64:	83 e0 0f             	and    $0xf,%eax
80102d67:	01 d0                	add    %edx,%eax
80102d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6f:	c1 e8 04             	shr    $0x4,%eax
80102d72:	89 c2                	mov    %eax,%edx
80102d74:	89 d0                	mov    %edx,%eax
80102d76:	c1 e0 02             	shl    $0x2,%eax
80102d79:	01 d0                	add    %edx,%eax
80102d7b:	01 c0                	add    %eax,%eax
80102d7d:	89 c2                	mov    %eax,%edx
80102d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d82:	83 e0 0f             	and    $0xf,%eax
80102d85:	01 d0                	add    %edx,%eax
80102d87:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8d:	c1 e8 04             	shr    $0x4,%eax
80102d90:	89 c2                	mov    %eax,%edx
80102d92:	89 d0                	mov    %edx,%eax
80102d94:	c1 e0 02             	shl    $0x2,%eax
80102d97:	01 d0                	add    %edx,%eax
80102d99:	01 c0                	add    %eax,%eax
80102d9b:	89 c2                	mov    %eax,%edx
80102d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102da0:	83 e0 0f             	and    $0xf,%eax
80102da3:	01 d0                	add    %edx,%eax
80102da5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dab:	c1 e8 04             	shr    $0x4,%eax
80102dae:	89 c2                	mov    %eax,%edx
80102db0:	89 d0                	mov    %edx,%eax
80102db2:	c1 e0 02             	shl    $0x2,%eax
80102db5:	01 d0                	add    %edx,%eax
80102db7:	01 c0                	add    %eax,%eax
80102db9:	89 c2                	mov    %eax,%edx
80102dbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbe:	83 e0 0f             	and    $0xf,%eax
80102dc1:	01 d0                	add    %edx,%eax
80102dc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc9:	c1 e8 04             	shr    $0x4,%eax
80102dcc:	89 c2                	mov    %eax,%edx
80102dce:	89 d0                	mov    %edx,%eax
80102dd0:	c1 e0 02             	shl    $0x2,%eax
80102dd3:	01 d0                	add    %edx,%eax
80102dd5:	01 c0                	add    %eax,%eax
80102dd7:	89 c2                	mov    %eax,%edx
80102dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ddc:	83 e0 0f             	and    $0xf,%eax
80102ddf:	01 d0                	add    %edx,%eax
80102de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de4:	8b 45 08             	mov    0x8(%ebp),%eax
80102de7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dea:	89 10                	mov    %edx,(%eax)
80102dec:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102def:	89 50 04             	mov    %edx,0x4(%eax)
80102df2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df5:	89 50 08             	mov    %edx,0x8(%eax)
80102df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dfb:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e01:	89 50 10             	mov    %edx,0x10(%eax)
80102e04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e07:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0d:	8b 40 14             	mov    0x14(%eax),%eax
80102e10:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e16:	8b 45 08             	mov    0x8(%ebp),%eax
80102e19:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1c:	90                   	nop
80102e1d:	c9                   	leave
80102e1e:	c3                   	ret

80102e1f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1f:	55                   	push   %ebp
80102e20:	89 e5                	mov    %esp,%ebp
80102e22:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e25:	83 ec 08             	sub    $0x8,%esp
80102e28:	68 51 a2 10 80       	push   $0x8010a251
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 cc 18 00 00       	call   80104703 <initlock>
80102e37:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e3a:	83 ec 08             	sub    $0x8,%esp
80102e3d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e40:	50                   	push   %eax
80102e41:	ff 75 08             	push   0x8(%ebp)
80102e44:	e8 8f e5 ff ff       	call   801013d8 <readsb>
80102e49:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4f:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e57:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5f:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e64:	e8 b3 01 00 00       	call   8010301c <recover_from_log>
}
80102e69:	90                   	nop
80102e6a:	c9                   	leave
80102e6b:	c3                   	ret

80102e6c <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6c:	55                   	push   %ebp
80102e6d:	89 e5                	mov    %esp,%ebp
80102e6f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e79:	e9 95 00 00 00       	jmp    80102f13 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e87:	01 d0                	add    %edx,%eax
80102e89:	83 c0 01             	add    $0x1,%eax
80102e8c:	89 c2                	mov    %eax,%edx
80102e8e:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e93:	83 ec 08             	sub    $0x8,%esp
80102e96:	52                   	push   %edx
80102e97:	50                   	push   %eax
80102e98:	e8 64 d3 ff ff       	call   80100201 <bread>
80102e9d:	83 c4 10             	add    $0x10,%esp
80102ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea6:	83 c0 10             	add    $0x10,%eax
80102ea9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eb0:	89 c2                	mov    %eax,%edx
80102eb2:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb7:	83 ec 08             	sub    $0x8,%esp
80102eba:	52                   	push   %edx
80102ebb:	50                   	push   %eax
80102ebc:	e8 40 d3 ff ff       	call   80100201 <bread>
80102ec1:	83 c4 10             	add    $0x10,%esp
80102ec4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eca:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ed0:	83 c0 5c             	add    $0x5c,%eax
80102ed3:	83 ec 04             	sub    $0x4,%esp
80102ed6:	68 00 02 00 00       	push   $0x200
80102edb:	52                   	push   %edx
80102edc:	50                   	push   %eax
80102edd:	e8 78 1b 00 00       	call   80104a5a <memmove>
80102ee2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee5:	83 ec 0c             	sub    $0xc,%esp
80102ee8:	ff 75 ec             	push   -0x14(%ebp)
80102eeb:	e8 4a d3 ff ff       	call   8010023a <bwrite>
80102ef0:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	ff 75 f0             	push   -0x10(%ebp)
80102ef9:	e8 85 d3 ff ff       	call   80100283 <brelse>
80102efe:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f01:	83 ec 0c             	sub    $0xc,%esp
80102f04:	ff 75 ec             	push   -0x14(%ebp)
80102f07:	e8 77 d3 ff ff       	call   80100283 <brelse>
80102f0c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f13:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f18:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f1b:	0f 8c 5d ff ff ff    	jl     80102e7e <install_trans+0x12>
  }
}
80102f21:	90                   	nop
80102f22:	90                   	nop
80102f23:	c9                   	leave
80102f24:	c3                   	ret

80102f25 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f25:	55                   	push   %ebp
80102f26:	89 e5                	mov    %esp,%ebp
80102f28:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f2b:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f30:	89 c2                	mov    %eax,%edx
80102f32:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f37:	83 ec 08             	sub    $0x8,%esp
80102f3a:	52                   	push   %edx
80102f3b:	50                   	push   %eax
80102f3c:	e8 c0 d2 ff ff       	call   80100201 <bread>
80102f41:	83 c4 10             	add    $0x10,%esp
80102f44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f4a:	83 c0 5c             	add    $0x5c,%eax
80102f4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f53:	8b 00                	mov    (%eax),%eax
80102f55:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f61:	eb 1b                	jmp    80102f7e <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f69:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f70:	83 c2 10             	add    $0x10,%edx
80102f73:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7e:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f83:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f86:	7c db                	jl     80102f63 <read_head+0x3e>
  }
  brelse(buf);
80102f88:	83 ec 0c             	sub    $0xc,%esp
80102f8b:	ff 75 f0             	push   -0x10(%ebp)
80102f8e:	e8 f0 d2 ff ff       	call   80100283 <brelse>
80102f93:	83 c4 10             	add    $0x10,%esp
}
80102f96:	90                   	nop
80102f97:	c9                   	leave
80102f98:	c3                   	ret

80102f99 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f99:	55                   	push   %ebp
80102f9a:	89 e5                	mov    %esp,%ebp
80102f9c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9f:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa4:	89 c2                	mov    %eax,%edx
80102fa6:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fab:	83 ec 08             	sub    $0x8,%esp
80102fae:	52                   	push   %edx
80102faf:	50                   	push   %eax
80102fb0:	e8 4c d2 ff ff       	call   80100201 <bread>
80102fb5:	83 c4 10             	add    $0x10,%esp
80102fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbe:	83 c0 5c             	add    $0x5c,%eax
80102fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc4:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcd:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd6:	eb 1b                	jmp    80102ff3 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdb:	83 c0 10             	add    $0x10,%eax
80102fde:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102feb:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff3:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ffb:	7c db                	jl     80102fd8 <write_head+0x3f>
  }
  bwrite(buf);
80102ffd:	83 ec 0c             	sub    $0xc,%esp
80103000:	ff 75 f0             	push   -0x10(%ebp)
80103003:	e8 32 d2 ff ff       	call   8010023a <bwrite>
80103008:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010300b:	83 ec 0c             	sub    $0xc,%esp
8010300e:	ff 75 f0             	push   -0x10(%ebp)
80103011:	e8 6d d2 ff ff       	call   80100283 <brelse>
80103016:	83 c4 10             	add    $0x10,%esp
}
80103019:	90                   	nop
8010301a:	c9                   	leave
8010301b:	c3                   	ret

8010301c <recover_from_log>:

static void
recover_from_log(void)
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
8010301f:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103022:	e8 fe fe ff ff       	call   80102f25 <read_head>
  install_trans(); // if committed, copy from log to disk
80103027:	e8 40 fe ff ff       	call   80102e6c <install_trans>
  log.lh.n = 0;
8010302c:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103033:	00 00 00 
  write_head(); // clear the log
80103036:	e8 5e ff ff ff       	call   80102f99 <write_head>
}
8010303b:	90                   	nop
8010303c:	c9                   	leave
8010303d:	c3                   	ret

8010303e <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303e:	55                   	push   %ebp
8010303f:	89 e5                	mov    %esp,%ebp
80103041:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103044:	83 ec 0c             	sub    $0xc,%esp
80103047:	68 20 41 19 80       	push   $0x80194120
8010304c:	e8 d4 16 00 00       	call   80104725 <acquire>
80103051:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103054:	a1 60 41 19 80       	mov    0x80194160,%eax
80103059:	85 c0                	test   %eax,%eax
8010305b:	74 17                	je     80103074 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305d:	83 ec 08             	sub    $0x8,%esp
80103060:	68 20 41 19 80       	push   $0x80194120
80103065:	68 20 41 19 80       	push   $0x80194120
8010306a:	e8 6a 12 00 00       	call   801042d9 <sleep>
8010306f:	83 c4 10             	add    $0x10,%esp
80103072:	eb e0                	jmp    80103054 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103074:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
8010307a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307f:	8d 50 01             	lea    0x1(%eax),%edx
80103082:	89 d0                	mov    %edx,%eax
80103084:	c1 e0 02             	shl    $0x2,%eax
80103087:	01 d0                	add    %edx,%eax
80103089:	01 c0                	add    %eax,%eax
8010308b:	01 c8                	add    %ecx,%eax
8010308d:	83 f8 1e             	cmp    $0x1e,%eax
80103090:	7e 17                	jle    801030a9 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103092:	83 ec 08             	sub    $0x8,%esp
80103095:	68 20 41 19 80       	push   $0x80194120
8010309a:	68 20 41 19 80       	push   $0x80194120
8010309f:	e8 35 12 00 00       	call   801042d9 <sleep>
801030a4:	83 c4 10             	add    $0x10,%esp
801030a7:	eb ab                	jmp    80103054 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a9:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ae:	83 c0 01             	add    $0x1,%eax
801030b1:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b6:	83 ec 0c             	sub    $0xc,%esp
801030b9:	68 20 41 19 80       	push   $0x80194120
801030be:	e8 d0 16 00 00       	call   80104793 <release>
801030c3:	83 c4 10             	add    $0x10,%esp
      break;
801030c6:	90                   	nop
    }
  }
}
801030c7:	90                   	nop
801030c8:	c9                   	leave
801030c9:	c3                   	ret

801030ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030ca:	55                   	push   %ebp
801030cb:	89 e5                	mov    %esp,%ebp
801030cd:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d7:	83 ec 0c             	sub    $0xc,%esp
801030da:	68 20 41 19 80       	push   $0x80194120
801030df:	e8 41 16 00 00       	call   80104725 <acquire>
801030e4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ec:	83 e8 01             	sub    $0x1,%eax
801030ef:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f4:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f9:	85 c0                	test   %eax,%eax
801030fb:	74 0d                	je     8010310a <end_op+0x40>
    panic("log.committing");
801030fd:	83 ec 0c             	sub    $0xc,%esp
80103100:	68 55 a2 10 80       	push   $0x8010a255
80103105:	e8 9f d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
8010310a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310f:	85 c0                	test   %eax,%eax
80103111:	75 13                	jne    80103126 <end_op+0x5c>
    do_commit = 1;
80103113:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010311a:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103121:	00 00 00 
80103124:	eb 10                	jmp    80103136 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103126:	83 ec 0c             	sub    $0xc,%esp
80103129:	68 20 41 19 80       	push   $0x80194120
8010312e:	e8 8d 12 00 00       	call   801043c0 <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 50 16 00 00       	call   80104793 <release>
80103143:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103146:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010314a:	74 3f                	je     8010318b <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314c:	e8 f6 00 00 00       	call   80103247 <commit>
    acquire(&log.lock);
80103151:	83 ec 0c             	sub    $0xc,%esp
80103154:	68 20 41 19 80       	push   $0x80194120
80103159:	e8 c7 15 00 00       	call   80104725 <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 48 12 00 00       	call   801043c0 <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 0b 16 00 00       	call   80104793 <release>
80103188:	83 c4 10             	add    $0x10,%esp
  }
}
8010318b:	90                   	nop
8010318c:	c9                   	leave
8010318d:	c3                   	ret

8010318e <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318e:	55                   	push   %ebp
8010318f:	89 e5                	mov    %esp,%ebp
80103191:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319b:	e9 95 00 00 00       	jmp    80103235 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801031a0:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a9:	01 d0                	add    %edx,%eax
801031ab:	83 c0 01             	add    $0x1,%eax
801031ae:	89 c2                	mov    %eax,%edx
801031b0:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b5:	83 ec 08             	sub    $0x8,%esp
801031b8:	52                   	push   %edx
801031b9:	50                   	push   %eax
801031ba:	e8 42 d0 ff ff       	call   80100201 <bread>
801031bf:	83 c4 10             	add    $0x10,%esp
801031c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c8:	83 c0 10             	add    $0x10,%eax
801031cb:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d2:	89 c2                	mov    %eax,%edx
801031d4:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d9:	83 ec 08             	sub    $0x8,%esp
801031dc:	52                   	push   %edx
801031dd:	50                   	push   %eax
801031de:	e8 1e d0 ff ff       	call   80100201 <bread>
801031e3:	83 c4 10             	add    $0x10,%esp
801031e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ec:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f2:	83 c0 5c             	add    $0x5c,%eax
801031f5:	83 ec 04             	sub    $0x4,%esp
801031f8:	68 00 02 00 00       	push   $0x200
801031fd:	52                   	push   %edx
801031fe:	50                   	push   %eax
801031ff:	e8 56 18 00 00       	call   80104a5a <memmove>
80103204:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103207:	83 ec 0c             	sub    $0xc,%esp
8010320a:	ff 75 f0             	push   -0x10(%ebp)
8010320d:	e8 28 d0 ff ff       	call   8010023a <bwrite>
80103212:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103215:	83 ec 0c             	sub    $0xc,%esp
80103218:	ff 75 ec             	push   -0x14(%ebp)
8010321b:	e8 63 d0 ff ff       	call   80100283 <brelse>
80103220:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103223:	83 ec 0c             	sub    $0xc,%esp
80103226:	ff 75 f0             	push   -0x10(%ebp)
80103229:	e8 55 d0 ff ff       	call   80100283 <brelse>
8010322e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103235:	a1 68 41 19 80       	mov    0x80194168,%eax
8010323a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323d:	0f 8c 5d ff ff ff    	jl     801031a0 <write_log+0x12>
  }
}
80103243:	90                   	nop
80103244:	90                   	nop
80103245:	c9                   	leave
80103246:	c3                   	ret

80103247 <commit>:

static void
commit()
{
80103247:	55                   	push   %ebp
80103248:	89 e5                	mov    %esp,%ebp
8010324a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103252:	85 c0                	test   %eax,%eax
80103254:	7e 1e                	jle    80103274 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103256:	e8 33 ff ff ff       	call   8010318e <write_log>
    write_head();    // Write header to disk -- the real commit
8010325b:	e8 39 fd ff ff       	call   80102f99 <write_head>
    install_trans(); // Now install writes to home locations
80103260:	e8 07 fc ff ff       	call   80102e6c <install_trans>
    log.lh.n = 0;
80103265:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326f:	e8 25 fd ff ff       	call   80102f99 <write_head>
  }
}
80103274:	90                   	nop
80103275:	c9                   	leave
80103276:	c3                   	ret

80103277 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103277:	55                   	push   %ebp
80103278:	89 e5                	mov    %esp,%ebp
8010327a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103282:	83 f8 1d             	cmp    $0x1d,%eax
80103285:	7f 12                	jg     80103299 <log_write+0x22>
80103287:	8b 15 68 41 19 80    	mov    0x80194168,%edx
8010328d:	a1 58 41 19 80       	mov    0x80194158,%eax
80103292:	83 e8 01             	sub    $0x1,%eax
80103295:	39 c2                	cmp    %eax,%edx
80103297:	7c 0d                	jl     801032a6 <log_write+0x2f>
    panic("too big a transaction");
80103299:	83 ec 0c             	sub    $0xc,%esp
8010329c:	68 64 a2 10 80       	push   $0x8010a264
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 7a a2 10 80       	push   $0x8010a27a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 5c 14 00 00       	call   80104725 <acquire>
801032c9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d3:	eb 1d                	jmp    801032f2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d8:	83 c0 10             	add    $0x10,%eax
801032db:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e2:	89 c2                	mov    %eax,%edx
801032e4:	8b 45 08             	mov    0x8(%ebp),%eax
801032e7:	8b 40 08             	mov    0x8(%eax),%eax
801032ea:	39 c2                	cmp    %eax,%edx
801032ec:	74 10                	je     801032fe <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f2:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032fa:	7c d9                	jl     801032d5 <log_write+0x5e>
801032fc:	eb 01                	jmp    801032ff <log_write+0x88>
      break;
801032fe:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	8b 40 08             	mov    0x8(%eax),%eax
80103305:	89 c2                	mov    %eax,%edx
80103307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330a:	83 c0 10             	add    $0x10,%eax
8010330d:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103314:	a1 68 41 19 80       	mov    0x80194168,%eax
80103319:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331c:	75 0d                	jne    8010332b <log_write+0xb4>
    log.lh.n++;
8010331e:	a1 68 41 19 80       	mov    0x80194168,%eax
80103323:	83 c0 01             	add    $0x1,%eax
80103326:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010332b:	8b 45 08             	mov    0x8(%ebp),%eax
8010332e:	8b 00                	mov    (%eax),%eax
80103330:	83 c8 04             	or     $0x4,%eax
80103333:	89 c2                	mov    %eax,%edx
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010333a:	83 ec 0c             	sub    $0xc,%esp
8010333d:	68 20 41 19 80       	push   $0x80194120
80103342:	e8 4c 14 00 00       	call   80104793 <release>
80103347:	83 c4 10             	add    $0x10,%esp
}
8010334a:	90                   	nop
8010334b:	c9                   	leave
8010334c:	c3                   	ret

8010334d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334d:	55                   	push   %ebp
8010334e:	89 e5                	mov    %esp,%ebp
80103350:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103353:	8b 55 08             	mov    0x8(%ebp),%edx
80103356:	8b 45 0c             	mov    0xc(%ebp),%eax
80103359:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335c:	f0 87 02             	lock xchg %eax,(%edx)
8010335f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103365:	c9                   	leave
80103366:	c3                   	ret

80103367 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103367:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010336b:	83 e4 f0             	and    $0xfffffff0,%esp
8010336e:	ff 71 fc             	push   -0x4(%ecx)
80103371:	55                   	push   %ebp
80103372:	89 e5                	mov    %esp,%ebp
80103374:	51                   	push   %ecx
80103375:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103378:	e8 83 4a 00 00       	call   80107e00 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 86 40 00 00       	call   8010741d <kvmalloc>
  mpinit_uefi();
80103397:	e8 2d 48 00 00       	call   80107bc9 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 0e 3b 00 00       	call   80106eb4 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 93 2e 00 00       	call   8010624d <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 e2 29 00 00       	call   80105da6 <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 58 6b 00 00       	call   80109f2b <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 69 4c 00 00       	call   8010805b <pci_init>
  arp_scan();
801033f2:	e8 9e 59 00 00       	call   80108d95 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f7:	e8 61 07 00 00       	call   80103b5d <userinit>

  mpmain();        // finish this processor's setup
801033fc:	e8 1a 00 00 00       	call   8010341b <mpmain>

80103401 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103401:	55                   	push   %ebp
80103402:	89 e5                	mov    %esp,%ebp
80103404:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103407:	e8 29 40 00 00       	call   80107435 <switchkvm>
  seginit();
8010340c:	e8 a3 3a 00 00       	call   80106eb4 <seginit>
  lapicinit();
80103411:	e8 ca f5 ff ff       	call   801029e0 <lapicinit>
  mpmain();
80103416:	e8 00 00 00 00       	call   8010341b <mpmain>

8010341b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010341b:	55                   	push   %ebp
8010341c:	89 e5                	mov    %esp,%ebp
8010341e:	53                   	push   %ebx
8010341f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103422:	e8 76 05 00 00       	call   8010399d <cpuid>
80103427:	89 c3                	mov    %eax,%ebx
80103429:	e8 6f 05 00 00       	call   8010399d <cpuid>
8010342e:	83 ec 04             	sub    $0x4,%esp
80103431:	53                   	push   %ebx
80103432:	50                   	push   %eax
80103433:	68 95 a2 10 80       	push   $0x8010a295
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 d7 2a 00 00       	call   80105f1c <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 6e 05 00 00       	call   801039b8 <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 86 0c 00 00       	call   801040e8 <scheduler>

80103462 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103462:	55                   	push   %ebp
80103463:	89 e5                	mov    %esp,%ebp
80103465:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103468:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346f:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103474:	83 ec 04             	sub    $0x4,%esp
80103477:	50                   	push   %eax
80103478:	68 18 f5 10 80       	push   $0x8010f518
8010347d:	ff 75 f0             	push   -0x10(%ebp)
80103480:	e8 d5 15 00 00       	call   80104a5a <memmove>
80103485:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103488:	c7 45 f4 80 6a 19 80 	movl   $0x80196a80,-0xc(%ebp)
8010348f:	eb 79                	jmp    8010350a <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103491:	e8 22 05 00 00       	call   801039b8 <mycpu>
80103496:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103499:	74 67                	je     80103502 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010349b:	e8 08 f3 ff ff       	call   801027a8 <kalloc>
801034a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a6:	83 e8 04             	sub    $0x4,%eax
801034a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ac:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b7:	83 e8 08             	sub    $0x8,%eax
801034ba:	c7 00 01 34 10 80    	movl   $0x80103401,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034c0:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ce:	83 e8 0c             	sub    $0xc,%eax
801034d1:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034df:	0f b6 00             	movzbl (%eax),%eax
801034e2:	0f b6 c0             	movzbl %al,%eax
801034e5:	83 ec 08             	sub    $0x8,%esp
801034e8:	52                   	push   %edx
801034e9:	50                   	push   %eax
801034ea:	e8 50 f6 ff ff       	call   80102b3f <lapicstartap>
801034ef:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f2:	90                   	nop
801034f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fc:	85 c0                	test   %eax,%eax
801034fe:	74 f3                	je     801034f3 <startothers+0x91>
80103500:	eb 01                	jmp    80103503 <startothers+0xa1>
      continue;
80103502:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103503:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
8010350a:	a1 40 6d 19 80       	mov    0x80196d40,%eax
8010350f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103515:	05 80 6a 19 80       	add    $0x80196a80,%eax
8010351a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351d:	0f 82 6e ff ff ff    	jb     80103491 <startothers+0x2f>
      ;
  }
}
80103523:	90                   	nop
80103524:	90                   	nop
80103525:	c9                   	leave
80103526:	c3                   	ret

80103527 <outb>:
{
80103527:	55                   	push   %ebp
80103528:	89 e5                	mov    %esp,%ebp
8010352a:	83 ec 08             	sub    $0x8,%esp
8010352d:	8b 55 08             	mov    0x8(%ebp),%edx
80103530:	8b 45 0c             	mov    0xc(%ebp),%eax
80103533:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave
80103545:	c3                   	ret

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d2 ff ff ff       	call   80103527 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 c0 ff ff ff       	call   80103527 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave
8010356c:	c3                   	ret

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 55 da ff ff       	call   80100fe7 <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 3e da ff ff       	call   80100fe7 <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e8 f1 ff ff       	call   801027a8 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 a9 a2 10 80       	push   $0x8010a2a9
8010360c:	50                   	push   %eax
8010360d:	e8 f1 10 00 00       	call   80104703 <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 8d f0 ff ff       	call   8010270e <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 0a da ff ff       	call   801010a5 <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 f0 d9 ff ff       	call   801010a5 <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave
801036be:	c3                   	ret

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 54 10 00 00       	call   80104725 <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 c8 0c 00 00       	call   801043c0 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 a5 0c 00 00       	call   801043c0 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 4f 10 00 00       	call   80104793 <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 bc ef ff ff       	call   8010270e <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 30 10 00 00       	call   80104793 <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave
80103769:	c3                   	ret

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 a8 0f 00 00       	call   80104725 <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 e2 0f 00 00       	call   80104793 <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 f1 0b 00 00       	call   801043c0 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 f1 0a 00 00       	call   801042d9 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 6e 0b 00 00       	call   801043c0 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 32 0f 00 00       	call   80104793 <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave
8010386b:	c3                   	ret

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 a7 0e 00 00       	call   80104725 <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 f8 0e 00 00       	call   80104793 <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 1b 0a 00 00       	call   801042d9 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 6f 0a 00 00       	call   801043c0 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 33 0e 00 00       	call   80104793 <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave
80103967:	c3                   	ret

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave
80103977:	c3                   	ret

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 b0 a2 10 80       	push   $0x8010a2b0
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 6c 0d 00 00       	call   80104703 <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave
8010399c:	c3                   	ret

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 6a 19 80       	sub    $0x80196a80,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave
801039b7:	c3                   	ret

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 b8 a2 10 80       	push   $0x8010a2b8
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1e f1 ff ff       	call   80102afc <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 6a 19 80       	add    $0x80196a80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 de a2 10 80       	push   $0x8010a2de
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave
80103a2f:	c3                   	ret

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 55 0e 00 00       	call   80104890 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 89 0e 00 00       	call   801048dd <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave
80103a58:	c3                   	ret

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 b9 0c 00 00       	call   80104725 <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 0e                	jmp    80103a86 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 27                	je     80103aa9 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103a86:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 42 19 80       	push   $0x80194200
80103a97:	e8 f7 0c 00 00       	call   80104793 <release>
80103a9c:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa4:	e9 b2 00 00 00       	jmp    80103b5b <allocproc+0x102>
      goto found;
80103aa9:	90                   	nop

found:
  p->state = EMBRYO;
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab4:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ab9:	8d 50 01             	lea    0x1(%eax),%edx
80103abc:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac5:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ac8:	83 ec 0c             	sub    $0xc,%esp
80103acb:	68 00 42 19 80       	push   $0x80194200
80103ad0:	e8 be 0c 00 00       	call   80104793 <release>
80103ad5:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad8:	e8 cb ec ff ff       	call   801027a8 <kalloc>
80103add:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae0:	89 42 08             	mov    %eax,0x8(%edx)
80103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae6:	8b 40 08             	mov    0x8(%eax),%eax
80103ae9:	85 c0                	test   %eax,%eax
80103aeb:	75 11                	jne    80103afe <allocproc+0xa5>
    p->state = UNUSED;
80103aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af7:	b8 00 00 00 00       	mov    $0x0,%eax
80103afc:	eb 5d                	jmp    80103b5b <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b01:	8b 40 08             	mov    0x8(%eax),%eax
80103b04:	05 00 10 00 00       	add    $0x1000,%eax
80103b09:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b16:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b19:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b1d:	ba 60 5d 10 80       	mov    $0x80105d60,%edx
80103b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b25:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b27:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b31:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b37:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3a:	83 ec 04             	sub    $0x4,%esp
80103b3d:	6a 14                	push   $0x14
80103b3f:	6a 00                	push   $0x0
80103b41:	50                   	push   %eax
80103b42:	e8 54 0e 00 00       	call   8010499b <memset>
80103b47:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b50:	ba 93 42 10 80       	mov    $0x80104293,%edx
80103b55:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5b:	c9                   	leave
80103b5c:	c3                   	ret

80103b5d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b5d:	55                   	push   %ebp
80103b5e:	89 e5                	mov    %esp,%ebp
80103b60:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b63:	e8 f1 fe ff ff       	call   80103a59 <allocproc>
80103b68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6e:	a3 34 62 19 80       	mov    %eax,0x80196234
  if((p->pgdir = setupkvm()) == 0){
80103b73:	e8 b8 37 00 00       	call   80107330 <setupkvm>
80103b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7b:	89 42 04             	mov    %eax,0x4(%edx)
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	8b 40 04             	mov    0x4(%eax),%eax
80103b84:	85 c0                	test   %eax,%eax
80103b86:	75 0d                	jne    80103b95 <userinit+0x38>
    panic("userinit: out of memory?");
80103b88:	83 ec 0c             	sub    $0xc,%esp
80103b8b:	68 ee a2 10 80       	push   $0x8010a2ee
80103b90:	e8 14 ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b95:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9d:	8b 40 04             	mov    0x4(%eax),%eax
80103ba0:	83 ec 04             	sub    $0x4,%esp
80103ba3:	52                   	push   %edx
80103ba4:	68 ec f4 10 80       	push   $0x8010f4ec
80103ba9:	50                   	push   %eax
80103baa:	e8 3e 3a 00 00       	call   801075ed <inituvm>
80103baf:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	8b 40 18             	mov    0x18(%eax),%eax
80103bc1:	83 ec 04             	sub    $0x4,%esp
80103bc4:	6a 4c                	push   $0x4c
80103bc6:	6a 00                	push   $0x0
80103bc8:	50                   	push   %eax
80103bc9:	e8 cd 0d 00 00       	call   8010499b <memset>
80103bce:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd4:	8b 40 18             	mov    0x18(%eax),%eax
80103bd7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be0:	8b 40 18             	mov    0x18(%eax),%eax
80103be3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bec:	8b 50 18             	mov    0x18(%eax),%edx
80103bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf2:	8b 40 18             	mov    0x18(%eax),%eax
80103bf5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bf9:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	8b 50 18             	mov    0x18(%eax),%edx
80103c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c06:	8b 40 18             	mov    0x18(%eax),%eax
80103c09:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c0d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c14:	8b 40 18             	mov    0x18(%eax),%eax
80103c17:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	8b 40 18             	mov    0x18(%eax),%eax
80103c24:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2e:	8b 40 18             	mov    0x18(%eax),%eax
80103c31:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	83 c0 6c             	add    $0x6c,%eax
80103c3e:	83 ec 04             	sub    $0x4,%esp
80103c41:	6a 10                	push   $0x10
80103c43:	68 07 a3 10 80       	push   $0x8010a307
80103c48:	50                   	push   %eax
80103c49:	e8 50 0f 00 00       	call   80104b9e <safestrcpy>
80103c4e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c51:	83 ec 0c             	sub    $0xc,%esp
80103c54:	68 10 a3 10 80       	push   $0x8010a310
80103c59:	e8 c7 e8 ff ff       	call   80102525 <namei>
80103c5e:	83 c4 10             	add    $0x10,%esp
80103c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c64:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c67:	83 ec 0c             	sub    $0xc,%esp
80103c6a:	68 00 42 19 80       	push   $0x80194200
80103c6f:	e8 b1 0a 00 00       	call   80104725 <acquire>
80103c74:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	68 00 42 19 80       	push   $0x80194200
80103c89:	e8 05 0b 00 00       	call   80104793 <release>
80103c8e:	83 c4 10             	add    $0x10,%esp
}
80103c91:	90                   	nop
80103c92:	c9                   	leave
80103c93:	c3                   	ret

80103c94 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c94:	55                   	push   %ebp
80103c95:	89 e5                	mov    %esp,%ebp
80103c97:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9a:	e8 91 fd ff ff       	call   80103a30 <myproc>
80103c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca5:	8b 00                	mov    (%eax),%eax
80103ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103caa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cae:	7e 2e                	jle    80103cde <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb0:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	01 c2                	add    %eax,%edx
80103cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbb:	8b 40 04             	mov    0x4(%eax),%eax
80103cbe:	83 ec 04             	sub    $0x4,%esp
80103cc1:	52                   	push   %edx
80103cc2:	ff 75 f4             	push   -0xc(%ebp)
80103cc5:	50                   	push   %eax
80103cc6:	e8 5f 3a 00 00       	call   8010772a <allocuvm>
80103ccb:	83 c4 10             	add    $0x10,%esp
80103cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd5:	75 3b                	jne    80103d12 <growproc+0x7e>
      return -1;
80103cd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdc:	eb 4f                	jmp    80103d2d <growproc+0x99>
  } else if(n < 0){
80103cde:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce2:	79 2e                	jns    80103d12 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce4:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cea:	01 c2                	add    %eax,%edx
80103cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cef:	8b 40 04             	mov    0x4(%eax),%eax
80103cf2:	83 ec 04             	sub    $0x4,%esp
80103cf5:	52                   	push   %edx
80103cf6:	ff 75 f4             	push   -0xc(%ebp)
80103cf9:	50                   	push   %eax
80103cfa:	e8 30 3b 00 00       	call   8010782f <deallocuvm>
80103cff:	83 c4 10             	add    $0x10,%esp
80103d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d09:	75 07                	jne    80103d12 <growproc+0x7e>
      return -1;
80103d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d10:	eb 1b                	jmp    80103d2d <growproc+0x99>
  }
  curproc->sz = sz;
80103d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d18:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1a:	83 ec 0c             	sub    $0xc,%esp
80103d1d:	ff 75 f0             	push   -0x10(%ebp)
80103d20:	e8 29 37 00 00       	call   8010744e <switchuvm>
80103d25:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d2d:	c9                   	leave
80103d2e:	c3                   	ret

80103d2f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d2f:	55                   	push   %ebp
80103d30:	89 e5                	mov    %esp,%ebp
80103d32:	57                   	push   %edi
80103d33:	56                   	push   %esi
80103d34:	53                   	push   %ebx
80103d35:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d38:	e8 f3 fc ff ff       	call   80103a30 <myproc>
80103d3d:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d40:	e8 14 fd ff ff       	call   80103a59 <allocproc>
80103d45:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d48:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4c:	75 0a                	jne    80103d58 <fork+0x29>
    return -1;
80103d4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d53:	e9 48 01 00 00       	jmp    80103ea0 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5b:	8b 10                	mov    (%eax),%edx
80103d5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d60:	8b 40 04             	mov    0x4(%eax),%eax
80103d63:	83 ec 08             	sub    $0x8,%esp
80103d66:	52                   	push   %edx
80103d67:	50                   	push   %eax
80103d68:	e8 60 3c 00 00       	call   801079cd <copyuvm>
80103d6d:	83 c4 10             	add    $0x10,%esp
80103d70:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d73:	89 42 04             	mov    %eax,0x4(%edx)
80103d76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d79:	8b 40 04             	mov    0x4(%eax),%eax
80103d7c:	85 c0                	test   %eax,%eax
80103d7e:	75 30                	jne    80103db0 <fork+0x81>
    kfree(np->kstack);
80103d80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d83:	8b 40 08             	mov    0x8(%eax),%eax
80103d86:	83 ec 0c             	sub    $0xc,%esp
80103d89:	50                   	push   %eax
80103d8a:	e8 7f e9 ff ff       	call   8010270e <kfree>
80103d8f:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d9f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dab:	e9 f0 00 00 00       	jmp    80103ea0 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db3:	8b 10                	mov    (%eax),%edx
80103db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db8:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc0:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc6:	8b 48 18             	mov    0x18(%eax),%ecx
80103dc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcc:	8b 40 18             	mov    0x18(%eax),%eax
80103dcf:	89 c2                	mov    %eax,%edx
80103dd1:	89 cb                	mov    %ecx,%ebx
80103dd3:	b8 13 00 00 00       	mov    $0x13,%eax
80103dd8:	89 d7                	mov    %edx,%edi
80103dda:	89 de                	mov    %ebx,%esi
80103ddc:	89 c1                	mov    %eax,%ecx
80103dde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de3:	8b 40 18             	mov    0x18(%eax),%eax
80103de6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df4:	eb 3b                	jmp    80103e31 <fork+0x102>
    if(curproc->ofile[i])
80103df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dfc:	83 c2 08             	add    $0x8,%edx
80103dff:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e03:	85 c0                	test   %eax,%eax
80103e05:	74 26                	je     80103e2d <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e0d:	83 c2 08             	add    $0x8,%edx
80103e10:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	50                   	push   %eax
80103e18:	e8 37 d2 ff ff       	call   80101054 <filedup>
80103e1d:	83 c4 10             	add    $0x10,%esp
80103e20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e26:	83 c1 08             	add    $0x8,%ecx
80103e29:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e2d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e31:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e35:	7e bf                	jle    80103df6 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3a:	8b 40 68             	mov    0x68(%eax),%eax
80103e3d:	83 ec 0c             	sub    $0xc,%esp
80103e40:	50                   	push   %eax
80103e41:	e8 72 db ff ff       	call   801019b8 <idup>
80103e46:	83 c4 10             	add    $0x10,%esp
80103e49:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4c:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e52:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e58:	83 c0 6c             	add    $0x6c,%eax
80103e5b:	83 ec 04             	sub    $0x4,%esp
80103e5e:	6a 10                	push   $0x10
80103e60:	52                   	push   %edx
80103e61:	50                   	push   %eax
80103e62:	e8 37 0d 00 00       	call   80104b9e <safestrcpy>
80103e67:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6d:	8b 40 10             	mov    0x10(%eax),%eax
80103e70:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e73:	83 ec 0c             	sub    $0xc,%esp
80103e76:	68 00 42 19 80       	push   $0x80194200
80103e7b:	e8 a5 08 00 00       	call   80104725 <acquire>
80103e80:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e86:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e8d:	83 ec 0c             	sub    $0xc,%esp
80103e90:	68 00 42 19 80       	push   $0x80194200
80103e95:	e8 f9 08 00 00       	call   80104793 <release>
80103e9a:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea3:	5b                   	pop    %ebx
80103ea4:	5e                   	pop    %esi
80103ea5:	5f                   	pop    %edi
80103ea6:	5d                   	pop    %ebp
80103ea7:	c3                   	ret

80103ea8 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ea8:	55                   	push   %ebp
80103ea9:	89 e5                	mov    %esp,%ebp
80103eab:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eae:	e8 7d fb ff ff       	call   80103a30 <myproc>
80103eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb6:	a1 34 62 19 80       	mov    0x80196234,%eax
80103ebb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ebe:	75 0d                	jne    80103ecd <exit+0x25>
    panic("init exiting");
80103ec0:	83 ec 0c             	sub    $0xc,%esp
80103ec3:	68 12 a3 10 80       	push   $0x8010a312
80103ec8:	e8 dc c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ecd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed4:	eb 3f                	jmp    80103f15 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edc:	83 c2 08             	add    $0x8,%edx
80103edf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee3:	85 c0                	test   %eax,%eax
80103ee5:	74 2a                	je     80103f11 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ee7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103eed:	83 c2 08             	add    $0x8,%edx
80103ef0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef4:	83 ec 0c             	sub    $0xc,%esp
80103ef7:	50                   	push   %eax
80103ef8:	e8 a8 d1 ff ff       	call   801010a5 <fileclose>
80103efd:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f06:	83 c2 08             	add    $0x8,%edx
80103f09:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f10:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f11:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f15:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f19:	7e bb                	jle    80103ed6 <exit+0x2e>
    }
  }

  begin_op();
80103f1b:	e8 1e f1 ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
80103f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f23:	8b 40 68             	mov    0x68(%eax),%eax
80103f26:	83 ec 0c             	sub    $0xc,%esp
80103f29:	50                   	push   %eax
80103f2a:	e8 24 dc ff ff       	call   80101b53 <iput>
80103f2f:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f32:	e8 93 f1 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80103f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f41:	83 ec 0c             	sub    $0xc,%esp
80103f44:	68 00 42 19 80       	push   $0x80194200
80103f49:	e8 d7 07 00 00       	call   80104725 <acquire>
80103f4e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f54:	8b 40 14             	mov    0x14(%eax),%eax
80103f57:	83 ec 0c             	sub    $0xc,%esp
80103f5a:	50                   	push   %eax
80103f5b:	e8 20 04 00 00       	call   80104380 <wakeup1>
80103f60:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f63:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f6a:	eb 37                	jmp    80103fa3 <exit+0xfb>
    if(p->parent == curproc){
80103f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6f:	8b 40 14             	mov    0x14(%eax),%eax
80103f72:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f75:	75 28                	jne    80103f9f <exit+0xf7>
      p->parent = initproc;
80103f77:	8b 15 34 62 19 80    	mov    0x80196234,%edx
80103f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f80:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f86:	8b 40 0c             	mov    0xc(%eax),%eax
80103f89:	83 f8 05             	cmp    $0x5,%eax
80103f8c:	75 11                	jne    80103f9f <exit+0xf7>
        wakeup1(initproc);
80103f8e:	a1 34 62 19 80       	mov    0x80196234,%eax
80103f93:	83 ec 0c             	sub    $0xc,%esp
80103f96:	50                   	push   %eax
80103f97:	e8 e4 03 00 00       	call   80104380 <wakeup1>
80103f9c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9f:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103fa3:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103faa:	72 c0                	jb     80103f6c <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103faf:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fb6:	e8 e5 01 00 00       	call   801041a0 <sched>
  panic("zombie exit");
80103fbb:	83 ec 0c             	sub    $0xc,%esp
80103fbe:	68 1f a3 10 80       	push   $0x8010a31f
80103fc3:	e8 e1 c5 ff ff       	call   801005a9 <panic>

80103fc8 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fce:	e8 5d fa ff ff       	call   80103a30 <myproc>
80103fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fd6:	83 ec 0c             	sub    $0xc,%esp
80103fd9:	68 00 42 19 80       	push   $0x80194200
80103fde:	e8 42 07 00 00       	call   80104725 <acquire>
80103fe3:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fe6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fed:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ff4:	e9 a1 00 00 00       	jmp    8010409a <wait+0xd2>
      if(p->parent != curproc)
80103ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffc:	8b 40 14             	mov    0x14(%eax),%eax
80103fff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104002:	0f 85 8d 00 00 00    	jne    80104095 <wait+0xcd>
        continue;
      havekids = 1;
80104008:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010400f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104012:	8b 40 0c             	mov    0xc(%eax),%eax
80104015:	83 f8 05             	cmp    $0x5,%eax
80104018:	75 7c                	jne    80104096 <wait+0xce>
        // Found one.
        pid = p->pid;
8010401a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401d:	8b 40 10             	mov    0x10(%eax),%eax
80104020:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104026:	8b 40 08             	mov    0x8(%eax),%eax
80104029:	83 ec 0c             	sub    $0xc,%esp
8010402c:	50                   	push   %eax
8010402d:	e8 dc e6 ff ff       	call   8010270e <kfree>
80104032:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104038:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010403f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104042:	8b 40 04             	mov    0x4(%eax),%eax
80104045:	83 ec 0c             	sub    $0xc,%esp
80104048:	50                   	push   %eax
80104049:	e8 a5 38 00 00       	call   801078f3 <freevm>
8010404e:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104054:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010406c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104079:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104080:	83 ec 0c             	sub    $0xc,%esp
80104083:	68 00 42 19 80       	push   $0x80194200
80104088:	e8 06 07 00 00       	call   80104793 <release>
8010408d:	83 c4 10             	add    $0x10,%esp
        return pid;
80104090:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104093:	eb 51                	jmp    801040e6 <wait+0x11e>
        continue;
80104095:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104096:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010409a:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801040a1:	0f 82 52 ff ff ff    	jb     80103ff9 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040ab:	74 0a                	je     801040b7 <wait+0xef>
801040ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b0:	8b 40 24             	mov    0x24(%eax),%eax
801040b3:	85 c0                	test   %eax,%eax
801040b5:	74 17                	je     801040ce <wait+0x106>
      release(&ptable.lock);
801040b7:	83 ec 0c             	sub    $0xc,%esp
801040ba:	68 00 42 19 80       	push   $0x80194200
801040bf:	e8 cf 06 00 00       	call   80104793 <release>
801040c4:	83 c4 10             	add    $0x10,%esp
      return -1;
801040c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cc:	eb 18                	jmp    801040e6 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040ce:	83 ec 08             	sub    $0x8,%esp
801040d1:	68 00 42 19 80       	push   $0x80194200
801040d6:	ff 75 ec             	push   -0x14(%ebp)
801040d9:	e8 fb 01 00 00       	call   801042d9 <sleep>
801040de:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040e1:	e9 00 ff ff ff       	jmp    80103fe6 <wait+0x1e>
  }
}
801040e6:	c9                   	leave
801040e7:	c3                   	ret

801040e8 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040e8:	55                   	push   %ebp
801040e9:	89 e5                	mov    %esp,%ebp
801040eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040ee:	e8 c5 f8 ff ff       	call   801039b8 <mycpu>
801040f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104100:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104103:	e8 70 f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104108:	83 ec 0c             	sub    $0xc,%esp
8010410b:	68 00 42 19 80       	push   $0x80194200
80104110:	e8 10 06 00 00       	call   80104725 <acquire>
80104115:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104118:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010411f:	eb 61                	jmp    80104182 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104124:	8b 40 0c             	mov    0xc(%eax),%eax
80104127:	83 f8 03             	cmp    $0x3,%eax
8010412a:	75 51                	jne    8010417d <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010412c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010412f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104132:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	ff 75 f4             	push   -0xc(%ebp)
8010413e:	e8 0b 33 00 00       	call   8010744e <switchuvm>
80104143:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104153:	8b 40 1c             	mov    0x1c(%eax),%eax
80104156:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104159:	83 c2 04             	add    $0x4,%edx
8010415c:	83 ec 08             	sub    $0x8,%esp
8010415f:	50                   	push   %eax
80104160:	52                   	push   %edx
80104161:	e8 aa 0a 00 00       	call   80104c10 <swtch>
80104166:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104169:	e8 c7 32 00 00       	call   80107435 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010416e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104171:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104178:	00 00 00 
8010417b:	eb 01                	jmp    8010417e <scheduler+0x96>
        continue;
8010417d:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010417e:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104182:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104189:	72 96                	jb     80104121 <scheduler+0x39>
    }
    release(&ptable.lock);
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	68 00 42 19 80       	push   $0x80194200
80104193:	e8 fb 05 00 00       	call   80104793 <release>
80104198:	83 c4 10             	add    $0x10,%esp
    sti();
8010419b:	e9 63 ff ff ff       	jmp    80104103 <scheduler+0x1b>

801041a0 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041a0:	55                   	push   %ebp
801041a1:	89 e5                	mov    %esp,%ebp
801041a3:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041a6:	e8 85 f8 ff ff       	call   80103a30 <myproc>
801041ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041ae:	83 ec 0c             	sub    $0xc,%esp
801041b1:	68 00 42 19 80       	push   $0x80194200
801041b6:	e8 a5 06 00 00       	call   80104860 <holding>
801041bb:	83 c4 10             	add    $0x10,%esp
801041be:	85 c0                	test   %eax,%eax
801041c0:	75 0d                	jne    801041cf <sched+0x2f>
    panic("sched ptable.lock");
801041c2:	83 ec 0c             	sub    $0xc,%esp
801041c5:	68 2b a3 10 80       	push   $0x8010a32b
801041ca:	e8 da c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041cf:	e8 e4 f7 ff ff       	call   801039b8 <mycpu>
801041d4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041da:	83 f8 01             	cmp    $0x1,%eax
801041dd:	74 0d                	je     801041ec <sched+0x4c>
    panic("sched locks");
801041df:	83 ec 0c             	sub    $0xc,%esp
801041e2:	68 3d a3 10 80       	push   $0x8010a33d
801041e7:	e8 bd c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ef:	8b 40 0c             	mov    0xc(%eax),%eax
801041f2:	83 f8 04             	cmp    $0x4,%eax
801041f5:	75 0d                	jne    80104204 <sched+0x64>
    panic("sched running");
801041f7:	83 ec 0c             	sub    $0xc,%esp
801041fa:	68 49 a3 10 80       	push   $0x8010a349
801041ff:	e8 a5 c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
80104204:	e8 5f f7 ff ff       	call   80103968 <readeflags>
80104209:	25 00 02 00 00       	and    $0x200,%eax
8010420e:	85 c0                	test   %eax,%eax
80104210:	74 0d                	je     8010421f <sched+0x7f>
    panic("sched interruptible");
80104212:	83 ec 0c             	sub    $0xc,%esp
80104215:	68 57 a3 10 80       	push   $0x8010a357
8010421a:	e8 8a c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
8010421f:	e8 94 f7 ff ff       	call   801039b8 <mycpu>
80104224:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010422a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010422d:	e8 86 f7 ff ff       	call   801039b8 <mycpu>
80104232:	8b 40 04             	mov    0x4(%eax),%eax
80104235:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104238:	83 c2 1c             	add    $0x1c,%edx
8010423b:	83 ec 08             	sub    $0x8,%esp
8010423e:	50                   	push   %eax
8010423f:	52                   	push   %edx
80104240:	e8 cb 09 00 00       	call   80104c10 <swtch>
80104245:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104248:	e8 6b f7 ff ff       	call   801039b8 <mycpu>
8010424d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104250:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104256:	90                   	nop
80104257:	c9                   	leave
80104258:	c3                   	ret

80104259 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104259:	55                   	push   %ebp
8010425a:	89 e5                	mov    %esp,%ebp
8010425c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010425f:	83 ec 0c             	sub    $0xc,%esp
80104262:	68 00 42 19 80       	push   $0x80194200
80104267:	e8 b9 04 00 00       	call   80104725 <acquire>
8010426c:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010426f:	e8 bc f7 ff ff       	call   80103a30 <myproc>
80104274:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010427b:	e8 20 ff ff ff       	call   801041a0 <sched>
  release(&ptable.lock);
80104280:	83 ec 0c             	sub    $0xc,%esp
80104283:	68 00 42 19 80       	push   $0x80194200
80104288:	e8 06 05 00 00       	call   80104793 <release>
8010428d:	83 c4 10             	add    $0x10,%esp
}
80104290:	90                   	nop
80104291:	c9                   	leave
80104292:	c3                   	ret

80104293 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104293:	55                   	push   %ebp
80104294:	89 e5                	mov    %esp,%ebp
80104296:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104299:	83 ec 0c             	sub    $0xc,%esp
8010429c:	68 00 42 19 80       	push   $0x80194200
801042a1:	e8 ed 04 00 00       	call   80104793 <release>
801042a6:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042a9:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042ae:	85 c0                	test   %eax,%eax
801042b0:	74 24                	je     801042d6 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042b2:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042b9:	00 00 00 
    iinit(ROOTDEV);
801042bc:	83 ec 0c             	sub    $0xc,%esp
801042bf:	6a 01                	push   $0x1
801042c1:	e8 bb d3 ff ff       	call   80101681 <iinit>
801042c6:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042c9:	83 ec 0c             	sub    $0xc,%esp
801042cc:	6a 01                	push   $0x1
801042ce:	e8 4c eb ff ff       	call   80102e1f <initlog>
801042d3:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042d6:	90                   	nop
801042d7:	c9                   	leave
801042d8:	c3                   	ret

801042d9 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042d9:	55                   	push   %ebp
801042da:	89 e5                	mov    %esp,%ebp
801042dc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042df:	e8 4c f7 ff ff       	call   80103a30 <myproc>
801042e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042eb:	75 0d                	jne    801042fa <sleep+0x21>
    panic("sleep");
801042ed:	83 ec 0c             	sub    $0xc,%esp
801042f0:	68 6b a3 10 80       	push   $0x8010a36b
801042f5:	e8 af c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
801042fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042fe:	75 0d                	jne    8010430d <sleep+0x34>
    panic("sleep without lk");
80104300:	83 ec 0c             	sub    $0xc,%esp
80104303:	68 71 a3 10 80       	push   $0x8010a371
80104308:	e8 9c c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010430d:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104314:	74 1e                	je     80104334 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	68 00 42 19 80       	push   $0x80194200
8010431e:	e8 02 04 00 00       	call   80104725 <acquire>
80104323:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104326:	83 ec 0c             	sub    $0xc,%esp
80104329:	ff 75 0c             	push   0xc(%ebp)
8010432c:	e8 62 04 00 00       	call   80104793 <release>
80104331:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104337:	8b 55 08             	mov    0x8(%ebp),%edx
8010433a:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010433d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104340:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104347:	e8 54 fe ff ff       	call   801041a0 <sched>

  // Tidy up.
  p->chan = 0;
8010434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434f:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104356:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010435d:	74 1e                	je     8010437d <sleep+0xa4>
    release(&ptable.lock);
8010435f:	83 ec 0c             	sub    $0xc,%esp
80104362:	68 00 42 19 80       	push   $0x80194200
80104367:	e8 27 04 00 00       	call   80104793 <release>
8010436c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010436f:	83 ec 0c             	sub    $0xc,%esp
80104372:	ff 75 0c             	push   0xc(%ebp)
80104375:	e8 ab 03 00 00       	call   80104725 <acquire>
8010437a:	83 c4 10             	add    $0x10,%esp
  }
}
8010437d:	90                   	nop
8010437e:	c9                   	leave
8010437f:	c3                   	ret

80104380 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104380:	55                   	push   %ebp
80104381:	89 e5                	mov    %esp,%ebp
80104383:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104386:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010438d:	eb 24                	jmp    801043b3 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010438f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104392:	8b 40 0c             	mov    0xc(%eax),%eax
80104395:	83 f8 02             	cmp    $0x2,%eax
80104398:	75 15                	jne    801043af <wakeup1+0x2f>
8010439a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439d:	8b 40 20             	mov    0x20(%eax),%eax
801043a0:	39 45 08             	cmp    %eax,0x8(%ebp)
801043a3:	75 0a                	jne    801043af <wakeup1+0x2f>
      p->state = RUNNABLE;
801043a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043af:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801043b3:	81 7d fc 34 62 19 80 	cmpl   $0x80196234,-0x4(%ebp)
801043ba:	72 d3                	jb     8010438f <wakeup1+0xf>
}
801043bc:	90                   	nop
801043bd:	90                   	nop
801043be:	c9                   	leave
801043bf:	c3                   	ret

801043c0 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043c0:	55                   	push   %ebp
801043c1:	89 e5                	mov    %esp,%ebp
801043c3:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043c6:	83 ec 0c             	sub    $0xc,%esp
801043c9:	68 00 42 19 80       	push   $0x80194200
801043ce:	e8 52 03 00 00       	call   80104725 <acquire>
801043d3:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043d6:	83 ec 0c             	sub    $0xc,%esp
801043d9:	ff 75 08             	push   0x8(%ebp)
801043dc:	e8 9f ff ff ff       	call   80104380 <wakeup1>
801043e1:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043e4:	83 ec 0c             	sub    $0xc,%esp
801043e7:	68 00 42 19 80       	push   $0x80194200
801043ec:	e8 a2 03 00 00       	call   80104793 <release>
801043f1:	83 c4 10             	add    $0x10,%esp
}
801043f4:	90                   	nop
801043f5:	c9                   	leave
801043f6:	c3                   	ret

801043f7 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043f7:	55                   	push   %ebp
801043f8:	89 e5                	mov    %esp,%ebp
801043fa:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043fd:	83 ec 0c             	sub    $0xc,%esp
80104400:	68 00 42 19 80       	push   $0x80194200
80104405:	e8 1b 03 00 00       	call   80104725 <acquire>
8010440a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010440d:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104414:	eb 45                	jmp    8010445b <kill+0x64>
    if(p->pid == pid){
80104416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104419:	8b 40 10             	mov    0x10(%eax),%eax
8010441c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010441f:	75 36                	jne    80104457 <kill+0x60>
      p->killed = 1;
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010442b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442e:	8b 40 0c             	mov    0xc(%eax),%eax
80104431:	83 f8 02             	cmp    $0x2,%eax
80104434:	75 0a                	jne    80104440 <kill+0x49>
        p->state = RUNNABLE;
80104436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104439:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104440:	83 ec 0c             	sub    $0xc,%esp
80104443:	68 00 42 19 80       	push   $0x80194200
80104448:	e8 46 03 00 00       	call   80104793 <release>
8010444d:	83 c4 10             	add    $0x10,%esp
      return 0;
80104450:	b8 00 00 00 00       	mov    $0x0,%eax
80104455:	eb 22                	jmp    80104479 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104457:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010445b:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104462:	72 b2                	jb     80104416 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104464:	83 ec 0c             	sub    $0xc,%esp
80104467:	68 00 42 19 80       	push   $0x80194200
8010446c:	e8 22 03 00 00       	call   80104793 <release>
80104471:	83 c4 10             	add    $0x10,%esp
  return -1;
80104474:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104479:	c9                   	leave
8010447a:	c3                   	ret

8010447b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010447b:	55                   	push   %ebp
8010447c:	89 e5                	mov    %esp,%ebp
8010447e:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104481:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104488:	e9 d7 00 00 00       	jmp    80104564 <procdump+0xe9>
    if(p->state == UNUSED)
8010448d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104490:	8b 40 0c             	mov    0xc(%eax),%eax
80104493:	85 c0                	test   %eax,%eax
80104495:	0f 84 c4 00 00 00    	je     8010455f <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010449b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449e:	8b 40 0c             	mov    0xc(%eax),%eax
801044a1:	83 f8 05             	cmp    $0x5,%eax
801044a4:	77 23                	ja     801044c9 <procdump+0x4e>
801044a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a9:	8b 40 0c             	mov    0xc(%eax),%eax
801044ac:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044b3:	85 c0                	test   %eax,%eax
801044b5:	74 12                	je     801044c9 <procdump+0x4e>
      state = states[p->state];
801044b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ba:	8b 40 0c             	mov    0xc(%eax),%eax
801044bd:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044c7:	eb 07                	jmp    801044d0 <procdump+0x55>
    else
      state = "???";
801044c9:	c7 45 ec 82 a3 10 80 	movl   $0x8010a382,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d3:	8d 50 6c             	lea    0x6c(%eax),%edx
801044d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d9:	8b 40 10             	mov    0x10(%eax),%eax
801044dc:	52                   	push   %edx
801044dd:	ff 75 ec             	push   -0x14(%ebp)
801044e0:	50                   	push   %eax
801044e1:	68 86 a3 10 80       	push   $0x8010a386
801044e6:	e8 09 bf ff ff       	call   801003f4 <cprintf>
801044eb:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f1:	8b 40 0c             	mov    0xc(%eax),%eax
801044f4:	83 f8 02             	cmp    $0x2,%eax
801044f7:	75 54                	jne    8010454d <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044fc:	8b 40 1c             	mov    0x1c(%eax),%eax
801044ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104502:	83 c0 08             	add    $0x8,%eax
80104505:	89 c2                	mov    %eax,%edx
80104507:	83 ec 08             	sub    $0x8,%esp
8010450a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010450d:	50                   	push   %eax
8010450e:	52                   	push   %edx
8010450f:	e8 d1 02 00 00       	call   801047e5 <getcallerpcs>
80104514:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104517:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010451e:	eb 1c                	jmp    8010453c <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104527:	83 ec 08             	sub    $0x8,%esp
8010452a:	50                   	push   %eax
8010452b:	68 8f a3 10 80       	push   $0x8010a38f
80104530:	e8 bf be ff ff       	call   801003f4 <cprintf>
80104535:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104538:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010453c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104540:	7f 0b                	jg     8010454d <procdump+0xd2>
80104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104545:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104549:	85 c0                	test   %eax,%eax
8010454b:	75 d3                	jne    80104520 <procdump+0xa5>
    }
    cprintf("\n");
8010454d:	83 ec 0c             	sub    $0xc,%esp
80104550:	68 93 a3 10 80       	push   $0x8010a393
80104555:	e8 9a be ff ff       	call   801003f4 <cprintf>
8010455a:	83 c4 10             	add    $0x10,%esp
8010455d:	eb 01                	jmp    80104560 <procdump+0xe5>
      continue;
8010455f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104560:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104564:	81 7d f0 34 62 19 80 	cmpl   $0x80196234,-0x10(%ebp)
8010456b:	0f 82 1c ff ff ff    	jb     8010448d <procdump+0x12>
  }
}
80104571:	90                   	nop
80104572:	90                   	nop
80104573:	c9                   	leave
80104574:	c3                   	ret

80104575 <uthread_init>:

int
uthread_init(int address)
{
80104575:	55                   	push   %ebp
80104576:	89 e5                	mov    %esp,%ebp
80104578:	83 ec 18             	sub    $0x18,%esp
  struct proc *cur_proc = myproc();
8010457b:	e8 b0 f4 ff ff       	call   80103a30 <myproc>
80104580:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("uthread_init: setting scheduler to %x\n", address);
80104583:	83 ec 08             	sub    $0x8,%esp
80104586:	ff 75 08             	push   0x8(%ebp)
80104589:	68 98 a3 10 80       	push   $0x8010a398
8010458e:	e8 61 be ff ff       	call   801003f4 <cprintf>
80104593:	83 c4 10             	add    $0x10,%esp
  cur_proc->scheduler = address;
80104596:	8b 55 08             	mov    0x8(%ebp),%edx
80104599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459c:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
8010459f:	b8 00 00 00 00       	mov    $0x0,%eax
801045a4:	c9                   	leave
801045a5:	c3                   	ret

801045a6 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801045a6:	55                   	push   %ebp
801045a7:	89 e5                	mov    %esp,%ebp
801045a9:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801045ac:	8b 45 08             	mov    0x8(%ebp),%eax
801045af:	83 c0 04             	add    $0x4,%eax
801045b2:	83 ec 08             	sub    $0x8,%esp
801045b5:	68 e9 a3 10 80       	push   $0x8010a3e9
801045ba:	50                   	push   %eax
801045bb:	e8 43 01 00 00       	call   80104703 <initlock>
801045c0:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801045c3:	8b 45 08             	mov    0x8(%ebp),%eax
801045c6:	8b 55 0c             	mov    0xc(%ebp),%edx
801045c9:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801045cc:	8b 45 08             	mov    0x8(%ebp),%eax
801045cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801045d5:	8b 45 08             	mov    0x8(%ebp),%eax
801045d8:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801045df:	90                   	nop
801045e0:	c9                   	leave
801045e1:	c3                   	ret

801045e2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801045e2:	55                   	push   %ebp
801045e3:	89 e5                	mov    %esp,%ebp
801045e5:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801045e8:	8b 45 08             	mov    0x8(%ebp),%eax
801045eb:	83 c0 04             	add    $0x4,%eax
801045ee:	83 ec 0c             	sub    $0xc,%esp
801045f1:	50                   	push   %eax
801045f2:	e8 2e 01 00 00       	call   80104725 <acquire>
801045f7:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045fa:	eb 15                	jmp    80104611 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801045fc:	8b 45 08             	mov    0x8(%ebp),%eax
801045ff:	83 c0 04             	add    $0x4,%eax
80104602:	83 ec 08             	sub    $0x8,%esp
80104605:	50                   	push   %eax
80104606:	ff 75 08             	push   0x8(%ebp)
80104609:	e8 cb fc ff ff       	call   801042d9 <sleep>
8010460e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104611:	8b 45 08             	mov    0x8(%ebp),%eax
80104614:	8b 00                	mov    (%eax),%eax
80104616:	85 c0                	test   %eax,%eax
80104618:	75 e2                	jne    801045fc <acquiresleep+0x1a>
  }
  lk->locked = 1;
8010461a:	8b 45 08             	mov    0x8(%ebp),%eax
8010461d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104623:	e8 08 f4 ff ff       	call   80103a30 <myproc>
80104628:	8b 50 10             	mov    0x10(%eax),%edx
8010462b:	8b 45 08             	mov    0x8(%ebp),%eax
8010462e:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104631:	8b 45 08             	mov    0x8(%ebp),%eax
80104634:	83 c0 04             	add    $0x4,%eax
80104637:	83 ec 0c             	sub    $0xc,%esp
8010463a:	50                   	push   %eax
8010463b:	e8 53 01 00 00       	call   80104793 <release>
80104640:	83 c4 10             	add    $0x10,%esp
}
80104643:	90                   	nop
80104644:	c9                   	leave
80104645:	c3                   	ret

80104646 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104646:	55                   	push   %ebp
80104647:	89 e5                	mov    %esp,%ebp
80104649:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010464c:	8b 45 08             	mov    0x8(%ebp),%eax
8010464f:	83 c0 04             	add    $0x4,%eax
80104652:	83 ec 0c             	sub    $0xc,%esp
80104655:	50                   	push   %eax
80104656:	e8 ca 00 00 00       	call   80104725 <acquire>
8010465b:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010465e:	8b 45 08             	mov    0x8(%ebp),%eax
80104661:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104667:	8b 45 08             	mov    0x8(%ebp),%eax
8010466a:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104671:	83 ec 0c             	sub    $0xc,%esp
80104674:	ff 75 08             	push   0x8(%ebp)
80104677:	e8 44 fd ff ff       	call   801043c0 <wakeup>
8010467c:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
8010467f:	8b 45 08             	mov    0x8(%ebp),%eax
80104682:	83 c0 04             	add    $0x4,%eax
80104685:	83 ec 0c             	sub    $0xc,%esp
80104688:	50                   	push   %eax
80104689:	e8 05 01 00 00       	call   80104793 <release>
8010468e:	83 c4 10             	add    $0x10,%esp
}
80104691:	90                   	nop
80104692:	c9                   	leave
80104693:	c3                   	ret

80104694 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104694:	55                   	push   %ebp
80104695:	89 e5                	mov    %esp,%ebp
80104697:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010469a:	8b 45 08             	mov    0x8(%ebp),%eax
8010469d:	83 c0 04             	add    $0x4,%eax
801046a0:	83 ec 0c             	sub    $0xc,%esp
801046a3:	50                   	push   %eax
801046a4:	e8 7c 00 00 00       	call   80104725 <acquire>
801046a9:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
801046ac:	8b 45 08             	mov    0x8(%ebp),%eax
801046af:	8b 00                	mov    (%eax),%eax
801046b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801046b4:	8b 45 08             	mov    0x8(%ebp),%eax
801046b7:	83 c0 04             	add    $0x4,%eax
801046ba:	83 ec 0c             	sub    $0xc,%esp
801046bd:	50                   	push   %eax
801046be:	e8 d0 00 00 00       	call   80104793 <release>
801046c3:	83 c4 10             	add    $0x10,%esp
  return r;
801046c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046c9:	c9                   	leave
801046ca:	c3                   	ret

801046cb <readeflags>:
{
801046cb:	55                   	push   %ebp
801046cc:	89 e5                	mov    %esp,%ebp
801046ce:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046d1:	9c                   	pushf
801046d2:	58                   	pop    %eax
801046d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046d9:	c9                   	leave
801046da:	c3                   	ret

801046db <cli>:
{
801046db:	55                   	push   %ebp
801046dc:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801046de:	fa                   	cli
}
801046df:	90                   	nop
801046e0:	5d                   	pop    %ebp
801046e1:	c3                   	ret

801046e2 <sti>:
{
801046e2:	55                   	push   %ebp
801046e3:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046e5:	fb                   	sti
}
801046e6:	90                   	nop
801046e7:	5d                   	pop    %ebp
801046e8:	c3                   	ret

801046e9 <xchg>:
{
801046e9:	55                   	push   %ebp
801046ea:	89 e5                	mov    %esp,%ebp
801046ec:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801046ef:	8b 55 08             	mov    0x8(%ebp),%edx
801046f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801046f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046f8:	f0 87 02             	lock xchg %eax,(%edx)
801046fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801046fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104701:	c9                   	leave
80104702:	c3                   	ret

80104703 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104703:	55                   	push   %ebp
80104704:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104706:	8b 45 08             	mov    0x8(%ebp),%eax
80104709:	8b 55 0c             	mov    0xc(%ebp),%edx
8010470c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010470f:	8b 45 08             	mov    0x8(%ebp),%eax
80104712:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104718:	8b 45 08             	mov    0x8(%ebp),%eax
8010471b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104722:	90                   	nop
80104723:	5d                   	pop    %ebp
80104724:	c3                   	ret

80104725 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104725:	55                   	push   %ebp
80104726:	89 e5                	mov    %esp,%ebp
80104728:	53                   	push   %ebx
80104729:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010472c:	e8 5f 01 00 00       	call   80104890 <pushcli>
  if(holding(lk)){
80104731:	8b 45 08             	mov    0x8(%ebp),%eax
80104734:	83 ec 0c             	sub    $0xc,%esp
80104737:	50                   	push   %eax
80104738:	e8 23 01 00 00       	call   80104860 <holding>
8010473d:	83 c4 10             	add    $0x10,%esp
80104740:	85 c0                	test   %eax,%eax
80104742:	74 0d                	je     80104751 <acquire+0x2c>
    panic("acquire");
80104744:	83 ec 0c             	sub    $0xc,%esp
80104747:	68 f4 a3 10 80       	push   $0x8010a3f4
8010474c:	e8 58 be ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104751:	90                   	nop
80104752:	8b 45 08             	mov    0x8(%ebp),%eax
80104755:	83 ec 08             	sub    $0x8,%esp
80104758:	6a 01                	push   $0x1
8010475a:	50                   	push   %eax
8010475b:	e8 89 ff ff ff       	call   801046e9 <xchg>
80104760:	83 c4 10             	add    $0x10,%esp
80104763:	85 c0                	test   %eax,%eax
80104765:	75 eb                	jne    80104752 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104767:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010476c:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010476f:	e8 44 f2 ff ff       	call   801039b8 <mycpu>
80104774:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104777:	8b 45 08             	mov    0x8(%ebp),%eax
8010477a:	83 c0 0c             	add    $0xc,%eax
8010477d:	83 ec 08             	sub    $0x8,%esp
80104780:	50                   	push   %eax
80104781:	8d 45 08             	lea    0x8(%ebp),%eax
80104784:	50                   	push   %eax
80104785:	e8 5b 00 00 00       	call   801047e5 <getcallerpcs>
8010478a:	83 c4 10             	add    $0x10,%esp
}
8010478d:	90                   	nop
8010478e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104791:	c9                   	leave
80104792:	c3                   	ret

80104793 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104793:	55                   	push   %ebp
80104794:	89 e5                	mov    %esp,%ebp
80104796:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104799:	83 ec 0c             	sub    $0xc,%esp
8010479c:	ff 75 08             	push   0x8(%ebp)
8010479f:	e8 bc 00 00 00       	call   80104860 <holding>
801047a4:	83 c4 10             	add    $0x10,%esp
801047a7:	85 c0                	test   %eax,%eax
801047a9:	75 0d                	jne    801047b8 <release+0x25>
    panic("release");
801047ab:	83 ec 0c             	sub    $0xc,%esp
801047ae:	68 fc a3 10 80       	push   $0x8010a3fc
801047b3:	e8 f1 bd ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801047b8:	8b 45 08             	mov    0x8(%ebp),%eax
801047bb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801047c2:	8b 45 08             	mov    0x8(%ebp),%eax
801047c5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801047cc:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801047d1:	8b 45 08             	mov    0x8(%ebp),%eax
801047d4:	8b 55 08             	mov    0x8(%ebp),%edx
801047d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801047dd:	e8 fb 00 00 00       	call   801048dd <popcli>
}
801047e2:	90                   	nop
801047e3:	c9                   	leave
801047e4:	c3                   	ret

801047e5 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801047e5:	55                   	push   %ebp
801047e6:	89 e5                	mov    %esp,%ebp
801047e8:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801047eb:	8b 45 08             	mov    0x8(%ebp),%eax
801047ee:	83 e8 08             	sub    $0x8,%eax
801047f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801047f4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801047fb:	eb 38                	jmp    80104835 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047fd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104801:	74 53                	je     80104856 <getcallerpcs+0x71>
80104803:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010480a:	76 4a                	jbe    80104856 <getcallerpcs+0x71>
8010480c:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104810:	74 44                	je     80104856 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104812:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104815:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010481c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010481f:	01 c2                	add    %eax,%edx
80104821:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104824:	8b 40 04             	mov    0x4(%eax),%eax
80104827:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104829:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010482c:	8b 00                	mov    (%eax),%eax
8010482e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104831:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104835:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104839:	7e c2                	jle    801047fd <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010483b:	eb 19                	jmp    80104856 <getcallerpcs+0x71>
    pcs[i] = 0;
8010483d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104840:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104847:	8b 45 0c             	mov    0xc(%ebp),%eax
8010484a:	01 d0                	add    %edx,%eax
8010484c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104852:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104856:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010485a:	7e e1                	jle    8010483d <getcallerpcs+0x58>
}
8010485c:	90                   	nop
8010485d:	90                   	nop
8010485e:	c9                   	leave
8010485f:	c3                   	ret

80104860 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104860:	55                   	push   %ebp
80104861:	89 e5                	mov    %esp,%ebp
80104863:	53                   	push   %ebx
80104864:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104867:	8b 45 08             	mov    0x8(%ebp),%eax
8010486a:	8b 00                	mov    (%eax),%eax
8010486c:	85 c0                	test   %eax,%eax
8010486e:	74 16                	je     80104886 <holding+0x26>
80104870:	8b 45 08             	mov    0x8(%ebp),%eax
80104873:	8b 58 08             	mov    0x8(%eax),%ebx
80104876:	e8 3d f1 ff ff       	call   801039b8 <mycpu>
8010487b:	39 c3                	cmp    %eax,%ebx
8010487d:	75 07                	jne    80104886 <holding+0x26>
8010487f:	b8 01 00 00 00       	mov    $0x1,%eax
80104884:	eb 05                	jmp    8010488b <holding+0x2b>
80104886:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010488b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010488e:	c9                   	leave
8010488f:	c3                   	ret

80104890 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104890:	55                   	push   %ebp
80104891:	89 e5                	mov    %esp,%ebp
80104893:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104896:	e8 30 fe ff ff       	call   801046cb <readeflags>
8010489b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010489e:	e8 38 fe ff ff       	call   801046db <cli>
  if(mycpu()->ncli == 0)
801048a3:	e8 10 f1 ff ff       	call   801039b8 <mycpu>
801048a8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801048ae:	85 c0                	test   %eax,%eax
801048b0:	75 14                	jne    801048c6 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801048b2:	e8 01 f1 ff ff       	call   801039b8 <mycpu>
801048b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048ba:	81 e2 00 02 00 00    	and    $0x200,%edx
801048c0:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801048c6:	e8 ed f0 ff ff       	call   801039b8 <mycpu>
801048cb:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048d1:	83 c2 01             	add    $0x1,%edx
801048d4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801048da:	90                   	nop
801048db:	c9                   	leave
801048dc:	c3                   	ret

801048dd <popcli>:

void
popcli(void)
{
801048dd:	55                   	push   %ebp
801048de:	89 e5                	mov    %esp,%ebp
801048e0:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801048e3:	e8 e3 fd ff ff       	call   801046cb <readeflags>
801048e8:	25 00 02 00 00       	and    $0x200,%eax
801048ed:	85 c0                	test   %eax,%eax
801048ef:	74 0d                	je     801048fe <popcli+0x21>
    panic("popcli - interruptible");
801048f1:	83 ec 0c             	sub    $0xc,%esp
801048f4:	68 04 a4 10 80       	push   $0x8010a404
801048f9:	e8 ab bc ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801048fe:	e8 b5 f0 ff ff       	call   801039b8 <mycpu>
80104903:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104909:	83 ea 01             	sub    $0x1,%edx
8010490c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104912:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104918:	85 c0                	test   %eax,%eax
8010491a:	79 0d                	jns    80104929 <popcli+0x4c>
    panic("popcli");
8010491c:	83 ec 0c             	sub    $0xc,%esp
8010491f:	68 1b a4 10 80       	push   $0x8010a41b
80104924:	e8 80 bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104929:	e8 8a f0 ff ff       	call   801039b8 <mycpu>
8010492e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104934:	85 c0                	test   %eax,%eax
80104936:	75 14                	jne    8010494c <popcli+0x6f>
80104938:	e8 7b f0 ff ff       	call   801039b8 <mycpu>
8010493d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104943:	85 c0                	test   %eax,%eax
80104945:	74 05                	je     8010494c <popcli+0x6f>
    sti();
80104947:	e8 96 fd ff ff       	call   801046e2 <sti>
}
8010494c:	90                   	nop
8010494d:	c9                   	leave
8010494e:	c3                   	ret

8010494f <stosb>:
{
8010494f:	55                   	push   %ebp
80104950:	89 e5                	mov    %esp,%ebp
80104952:	57                   	push   %edi
80104953:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104954:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104957:	8b 55 10             	mov    0x10(%ebp),%edx
8010495a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010495d:	89 cb                	mov    %ecx,%ebx
8010495f:	89 df                	mov    %ebx,%edi
80104961:	89 d1                	mov    %edx,%ecx
80104963:	fc                   	cld
80104964:	f3 aa                	rep stos %al,%es:(%edi)
80104966:	89 ca                	mov    %ecx,%edx
80104968:	89 fb                	mov    %edi,%ebx
8010496a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010496d:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104970:	90                   	nop
80104971:	5b                   	pop    %ebx
80104972:	5f                   	pop    %edi
80104973:	5d                   	pop    %ebp
80104974:	c3                   	ret

80104975 <stosl>:
{
80104975:	55                   	push   %ebp
80104976:	89 e5                	mov    %esp,%ebp
80104978:	57                   	push   %edi
80104979:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010497a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010497d:	8b 55 10             	mov    0x10(%ebp),%edx
80104980:	8b 45 0c             	mov    0xc(%ebp),%eax
80104983:	89 cb                	mov    %ecx,%ebx
80104985:	89 df                	mov    %ebx,%edi
80104987:	89 d1                	mov    %edx,%ecx
80104989:	fc                   	cld
8010498a:	f3 ab                	rep stos %eax,%es:(%edi)
8010498c:	89 ca                	mov    %ecx,%edx
8010498e:	89 fb                	mov    %edi,%ebx
80104990:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104993:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104996:	90                   	nop
80104997:	5b                   	pop    %ebx
80104998:	5f                   	pop    %edi
80104999:	5d                   	pop    %ebp
8010499a:	c3                   	ret

8010499b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010499b:	55                   	push   %ebp
8010499c:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010499e:	8b 45 08             	mov    0x8(%ebp),%eax
801049a1:	83 e0 03             	and    $0x3,%eax
801049a4:	85 c0                	test   %eax,%eax
801049a6:	75 43                	jne    801049eb <memset+0x50>
801049a8:	8b 45 10             	mov    0x10(%ebp),%eax
801049ab:	83 e0 03             	and    $0x3,%eax
801049ae:	85 c0                	test   %eax,%eax
801049b0:	75 39                	jne    801049eb <memset+0x50>
    c &= 0xFF;
801049b2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801049b9:	8b 45 10             	mov    0x10(%ebp),%eax
801049bc:	c1 e8 02             	shr    $0x2,%eax
801049bf:	89 c1                	mov    %eax,%ecx
801049c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801049c4:	c1 e0 18             	shl    $0x18,%eax
801049c7:	89 c2                	mov    %eax,%edx
801049c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801049cc:	c1 e0 10             	shl    $0x10,%eax
801049cf:	09 c2                	or     %eax,%edx
801049d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801049d4:	c1 e0 08             	shl    $0x8,%eax
801049d7:	09 d0                	or     %edx,%eax
801049d9:	0b 45 0c             	or     0xc(%ebp),%eax
801049dc:	51                   	push   %ecx
801049dd:	50                   	push   %eax
801049de:	ff 75 08             	push   0x8(%ebp)
801049e1:	e8 8f ff ff ff       	call   80104975 <stosl>
801049e6:	83 c4 0c             	add    $0xc,%esp
801049e9:	eb 12                	jmp    801049fd <memset+0x62>
  } else
    stosb(dst, c, n);
801049eb:	8b 45 10             	mov    0x10(%ebp),%eax
801049ee:	50                   	push   %eax
801049ef:	ff 75 0c             	push   0xc(%ebp)
801049f2:	ff 75 08             	push   0x8(%ebp)
801049f5:	e8 55 ff ff ff       	call   8010494f <stosb>
801049fa:	83 c4 0c             	add    $0xc,%esp
  return dst;
801049fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104a00:	c9                   	leave
80104a01:	c3                   	ret

80104a02 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104a02:	55                   	push   %ebp
80104a03:	89 e5                	mov    %esp,%ebp
80104a05:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104a08:	8b 45 08             	mov    0x8(%ebp),%eax
80104a0b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a11:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104a14:	eb 2e                	jmp    80104a44 <memcmp+0x42>
    if(*s1 != *s2)
80104a16:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a19:	0f b6 10             	movzbl (%eax),%edx
80104a1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a1f:	0f b6 00             	movzbl (%eax),%eax
80104a22:	38 c2                	cmp    %al,%dl
80104a24:	74 16                	je     80104a3c <memcmp+0x3a>
      return *s1 - *s2;
80104a26:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a29:	0f b6 00             	movzbl (%eax),%eax
80104a2c:	0f b6 d0             	movzbl %al,%edx
80104a2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a32:	0f b6 00             	movzbl (%eax),%eax
80104a35:	0f b6 c0             	movzbl %al,%eax
80104a38:	29 c2                	sub    %eax,%edx
80104a3a:	eb 1a                	jmp    80104a56 <memcmp+0x54>
    s1++, s2++;
80104a3c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a40:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104a44:	8b 45 10             	mov    0x10(%ebp),%eax
80104a47:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a4a:	89 55 10             	mov    %edx,0x10(%ebp)
80104a4d:	85 c0                	test   %eax,%eax
80104a4f:	75 c5                	jne    80104a16 <memcmp+0x14>
  }

  return 0;
80104a51:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104a56:	89 d0                	mov    %edx,%eax
80104a58:	c9                   	leave
80104a59:	c3                   	ret

80104a5a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a5a:	55                   	push   %ebp
80104a5b:	89 e5                	mov    %esp,%ebp
80104a5d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104a60:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a63:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104a66:	8b 45 08             	mov    0x8(%ebp),%eax
80104a69:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104a6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a6f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104a72:	73 54                	jae    80104ac8 <memmove+0x6e>
80104a74:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a77:	8b 45 10             	mov    0x10(%ebp),%eax
80104a7a:	01 d0                	add    %edx,%eax
80104a7c:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104a7f:	73 47                	jae    80104ac8 <memmove+0x6e>
    s += n;
80104a81:	8b 45 10             	mov    0x10(%ebp),%eax
80104a84:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104a87:	8b 45 10             	mov    0x10(%ebp),%eax
80104a8a:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104a8d:	eb 13                	jmp    80104aa2 <memmove+0x48>
      *--d = *--s;
80104a8f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104a93:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104a97:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a9a:	0f b6 10             	movzbl (%eax),%edx
80104a9d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104aa0:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104aa2:	8b 45 10             	mov    0x10(%ebp),%eax
80104aa5:	8d 50 ff             	lea    -0x1(%eax),%edx
80104aa8:	89 55 10             	mov    %edx,0x10(%ebp)
80104aab:	85 c0                	test   %eax,%eax
80104aad:	75 e0                	jne    80104a8f <memmove+0x35>
  if(s < d && s + n > d){
80104aaf:	eb 24                	jmp    80104ad5 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104ab1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ab4:	8d 42 01             	lea    0x1(%edx),%eax
80104ab7:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104aba:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104abd:	8d 48 01             	lea    0x1(%eax),%ecx
80104ac0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ac3:	0f b6 12             	movzbl (%edx),%edx
80104ac6:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ac8:	8b 45 10             	mov    0x10(%ebp),%eax
80104acb:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ace:	89 55 10             	mov    %edx,0x10(%ebp)
80104ad1:	85 c0                	test   %eax,%eax
80104ad3:	75 dc                	jne    80104ab1 <memmove+0x57>

  return dst;
80104ad5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ad8:	c9                   	leave
80104ad9:	c3                   	ret

80104ada <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ada:	55                   	push   %ebp
80104adb:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104add:	ff 75 10             	push   0x10(%ebp)
80104ae0:	ff 75 0c             	push   0xc(%ebp)
80104ae3:	ff 75 08             	push   0x8(%ebp)
80104ae6:	e8 6f ff ff ff       	call   80104a5a <memmove>
80104aeb:	83 c4 0c             	add    $0xc,%esp
}
80104aee:	c9                   	leave
80104aef:	c3                   	ret

80104af0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104af0:	55                   	push   %ebp
80104af1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104af3:	eb 0c                	jmp    80104b01 <strncmp+0x11>
    n--, p++, q++;
80104af5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104af9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104afd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104b01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b05:	74 1a                	je     80104b21 <strncmp+0x31>
80104b07:	8b 45 08             	mov    0x8(%ebp),%eax
80104b0a:	0f b6 00             	movzbl (%eax),%eax
80104b0d:	84 c0                	test   %al,%al
80104b0f:	74 10                	je     80104b21 <strncmp+0x31>
80104b11:	8b 45 08             	mov    0x8(%ebp),%eax
80104b14:	0f b6 10             	movzbl (%eax),%edx
80104b17:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b1a:	0f b6 00             	movzbl (%eax),%eax
80104b1d:	38 c2                	cmp    %al,%dl
80104b1f:	74 d4                	je     80104af5 <strncmp+0x5>
  if(n == 0)
80104b21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b25:	75 07                	jne    80104b2e <strncmp+0x3e>
    return 0;
80104b27:	ba 00 00 00 00       	mov    $0x0,%edx
80104b2c:	eb 14                	jmp    80104b42 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80104b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b31:	0f b6 00             	movzbl (%eax),%eax
80104b34:	0f b6 d0             	movzbl %al,%edx
80104b37:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b3a:	0f b6 00             	movzbl (%eax),%eax
80104b3d:	0f b6 c0             	movzbl %al,%eax
80104b40:	29 c2                	sub    %eax,%edx
}
80104b42:	89 d0                	mov    %edx,%eax
80104b44:	5d                   	pop    %ebp
80104b45:	c3                   	ret

80104b46 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b46:	55                   	push   %ebp
80104b47:	89 e5                	mov    %esp,%ebp
80104b49:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b52:	90                   	nop
80104b53:	8b 45 10             	mov    0x10(%ebp),%eax
80104b56:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b59:	89 55 10             	mov    %edx,0x10(%ebp)
80104b5c:	85 c0                	test   %eax,%eax
80104b5e:	7e 2c                	jle    80104b8c <strncpy+0x46>
80104b60:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b63:	8d 42 01             	lea    0x1(%edx),%eax
80104b66:	89 45 0c             	mov    %eax,0xc(%ebp)
80104b69:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6c:	8d 48 01             	lea    0x1(%eax),%ecx
80104b6f:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104b72:	0f b6 12             	movzbl (%edx),%edx
80104b75:	88 10                	mov    %dl,(%eax)
80104b77:	0f b6 00             	movzbl (%eax),%eax
80104b7a:	84 c0                	test   %al,%al
80104b7c:	75 d5                	jne    80104b53 <strncpy+0xd>
    ;
  while(n-- > 0)
80104b7e:	eb 0c                	jmp    80104b8c <strncpy+0x46>
    *s++ = 0;
80104b80:	8b 45 08             	mov    0x8(%ebp),%eax
80104b83:	8d 50 01             	lea    0x1(%eax),%edx
80104b86:	89 55 08             	mov    %edx,0x8(%ebp)
80104b89:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104b8c:	8b 45 10             	mov    0x10(%ebp),%eax
80104b8f:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b92:	89 55 10             	mov    %edx,0x10(%ebp)
80104b95:	85 c0                	test   %eax,%eax
80104b97:	7f e7                	jg     80104b80 <strncpy+0x3a>
  return os;
80104b99:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b9c:	c9                   	leave
80104b9d:	c3                   	ret

80104b9e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104b9e:	55                   	push   %ebp
80104b9f:	89 e5                	mov    %esp,%ebp
80104ba1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104baa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104bae:	7f 05                	jg     80104bb5 <safestrcpy+0x17>
    return os;
80104bb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104bb3:	eb 32                	jmp    80104be7 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104bb5:	90                   	nop
80104bb6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104bba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104bbe:	7e 1e                	jle    80104bde <safestrcpy+0x40>
80104bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bc3:	8d 42 01             	lea    0x1(%edx),%eax
80104bc6:	89 45 0c             	mov    %eax,0xc(%ebp)
80104bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80104bcc:	8d 48 01             	lea    0x1(%eax),%ecx
80104bcf:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104bd2:	0f b6 12             	movzbl (%edx),%edx
80104bd5:	88 10                	mov    %dl,(%eax)
80104bd7:	0f b6 00             	movzbl (%eax),%eax
80104bda:	84 c0                	test   %al,%al
80104bdc:	75 d8                	jne    80104bb6 <safestrcpy+0x18>
    ;
  *s = 0;
80104bde:	8b 45 08             	mov    0x8(%ebp),%eax
80104be1:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104be4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104be7:	c9                   	leave
80104be8:	c3                   	ret

80104be9 <strlen>:

int
strlen(const char *s)
{
80104be9:	55                   	push   %ebp
80104bea:	89 e5                	mov    %esp,%ebp
80104bec:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104bef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104bf6:	eb 04                	jmp    80104bfc <strlen+0x13>
80104bf8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104bfc:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bff:	8b 45 08             	mov    0x8(%ebp),%eax
80104c02:	01 d0                	add    %edx,%eax
80104c04:	0f b6 00             	movzbl (%eax),%eax
80104c07:	84 c0                	test   %al,%al
80104c09:	75 ed                	jne    80104bf8 <strlen+0xf>
    ;
  return n;
80104c0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c0e:	c9                   	leave
80104c0f:	c3                   	ret

80104c10 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104c10:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104c14:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104c18:	55                   	push   %ebp
  pushl %ebx
80104c19:	53                   	push   %ebx
  pushl %esi
80104c1a:	56                   	push   %esi
  pushl %edi
80104c1b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c1c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c1e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104c20:	5f                   	pop    %edi
  popl %esi
80104c21:	5e                   	pop    %esi
  popl %ebx
80104c22:	5b                   	pop    %ebx
  popl %ebp
80104c23:	5d                   	pop    %ebp
  ret
80104c24:	c3                   	ret

80104c25 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c25:	55                   	push   %ebp
80104c26:	89 e5                	mov    %esp,%ebp
80104c28:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104c2b:	e8 00 ee ff ff       	call   80103a30 <myproc>
80104c30:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c36:	8b 00                	mov    (%eax),%eax
80104c38:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c3b:	73 0f                	jae    80104c4c <fetchint+0x27>
80104c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104c40:	8d 50 04             	lea    0x4(%eax),%edx
80104c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c46:	8b 00                	mov    (%eax),%eax
80104c48:	39 d0                	cmp    %edx,%eax
80104c4a:	73 07                	jae    80104c53 <fetchint+0x2e>
    return -1;
80104c4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c51:	eb 0f                	jmp    80104c62 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104c53:	8b 45 08             	mov    0x8(%ebp),%eax
80104c56:	8b 10                	mov    (%eax),%edx
80104c58:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c5b:	89 10                	mov    %edx,(%eax)
  return 0;
80104c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c62:	c9                   	leave
80104c63:	c3                   	ret

80104c64 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c64:	55                   	push   %ebp
80104c65:	89 e5                	mov    %esp,%ebp
80104c67:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104c6a:	e8 c1 ed ff ff       	call   80103a30 <myproc>
80104c6f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c75:	8b 00                	mov    (%eax),%eax
80104c77:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c7a:	72 07                	jb     80104c83 <fetchstr+0x1f>
    return -1;
80104c7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c81:	eb 41                	jmp    80104cc4 <fetchstr+0x60>
  *pp = (char*)addr;
80104c83:	8b 55 08             	mov    0x8(%ebp),%edx
80104c86:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c89:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c8e:	8b 00                	mov    (%eax),%eax
80104c90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104c93:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c96:	8b 00                	mov    (%eax),%eax
80104c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c9b:	eb 1a                	jmp    80104cb7 <fetchstr+0x53>
    if(*s == 0)
80104c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca0:	0f b6 00             	movzbl (%eax),%eax
80104ca3:	84 c0                	test   %al,%al
80104ca5:	75 0c                	jne    80104cb3 <fetchstr+0x4f>
      return s - *pp;
80104ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104caa:	8b 10                	mov    (%eax),%edx
80104cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104caf:	29 d0                	sub    %edx,%eax
80104cb1:	eb 11                	jmp    80104cc4 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104cb3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104cbd:	72 de                	jb     80104c9d <fetchstr+0x39>
  }
  return -1;
80104cbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cc4:	c9                   	leave
80104cc5:	c3                   	ret

80104cc6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104cc6:	55                   	push   %ebp
80104cc7:	89 e5                	mov    %esp,%ebp
80104cc9:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ccc:	e8 5f ed ff ff       	call   80103a30 <myproc>
80104cd1:	8b 40 18             	mov    0x18(%eax),%eax
80104cd4:	8b 40 44             	mov    0x44(%eax),%eax
80104cd7:	8b 55 08             	mov    0x8(%ebp),%edx
80104cda:	c1 e2 02             	shl    $0x2,%edx
80104cdd:	01 d0                	add    %edx,%eax
80104cdf:	83 c0 04             	add    $0x4,%eax
80104ce2:	83 ec 08             	sub    $0x8,%esp
80104ce5:	ff 75 0c             	push   0xc(%ebp)
80104ce8:	50                   	push   %eax
80104ce9:	e8 37 ff ff ff       	call   80104c25 <fetchint>
80104cee:	83 c4 10             	add    $0x10,%esp
}
80104cf1:	c9                   	leave
80104cf2:	c3                   	ret

80104cf3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104cf3:	55                   	push   %ebp
80104cf4:	89 e5                	mov    %esp,%ebp
80104cf6:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104cf9:	e8 32 ed ff ff       	call   80103a30 <myproc>
80104cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104d01:	83 ec 08             	sub    $0x8,%esp
80104d04:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d07:	50                   	push   %eax
80104d08:	ff 75 08             	push   0x8(%ebp)
80104d0b:	e8 b6 ff ff ff       	call   80104cc6 <argint>
80104d10:	83 c4 10             	add    $0x10,%esp
80104d13:	85 c0                	test   %eax,%eax
80104d15:	79 07                	jns    80104d1e <argptr+0x2b>
    return -1;
80104d17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d1c:	eb 3b                	jmp    80104d59 <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d22:	78 1f                	js     80104d43 <argptr+0x50>
80104d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d27:	8b 00                	mov    (%eax),%eax
80104d29:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d2c:	39 c2                	cmp    %eax,%edx
80104d2e:	73 13                	jae    80104d43 <argptr+0x50>
80104d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d33:	89 c2                	mov    %eax,%edx
80104d35:	8b 45 10             	mov    0x10(%ebp),%eax
80104d38:	01 c2                	add    %eax,%edx
80104d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3d:	8b 00                	mov    (%eax),%eax
80104d3f:	39 d0                	cmp    %edx,%eax
80104d41:	73 07                	jae    80104d4a <argptr+0x57>
    return -1;
80104d43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d48:	eb 0f                	jmp    80104d59 <argptr+0x66>
  *pp = (char*)i;
80104d4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d4d:	89 c2                	mov    %eax,%edx
80104d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d52:	89 10                	mov    %edx,(%eax)
  return 0;
80104d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d59:	c9                   	leave
80104d5a:	c3                   	ret

80104d5b <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d5b:	55                   	push   %ebp
80104d5c:	89 e5                	mov    %esp,%ebp
80104d5e:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104d61:	83 ec 08             	sub    $0x8,%esp
80104d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d67:	50                   	push   %eax
80104d68:	ff 75 08             	push   0x8(%ebp)
80104d6b:	e8 56 ff ff ff       	call   80104cc6 <argint>
80104d70:	83 c4 10             	add    $0x10,%esp
80104d73:	85 c0                	test   %eax,%eax
80104d75:	79 07                	jns    80104d7e <argstr+0x23>
    return -1;
80104d77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d7c:	eb 12                	jmp    80104d90 <argstr+0x35>
  return fetchstr(addr, pp);
80104d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d81:	83 ec 08             	sub    $0x8,%esp
80104d84:	ff 75 0c             	push   0xc(%ebp)
80104d87:	50                   	push   %eax
80104d88:	e8 d7 fe ff ff       	call   80104c64 <fetchstr>
80104d8d:	83 c4 10             	add    $0x10,%esp
}
80104d90:	c9                   	leave
80104d91:	c3                   	ret

80104d92 <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80104d92:	55                   	push   %ebp
80104d93:	89 e5                	mov    %esp,%ebp
80104d95:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104d98:	e8 93 ec ff ff       	call   80103a30 <myproc>
80104d9d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da3:	8b 40 18             	mov    0x18(%eax),%eax
80104da6:	8b 40 1c             	mov    0x1c(%eax),%eax
80104da9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104dac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104db0:	7e 2f                	jle    80104de1 <syscall+0x4f>
80104db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db5:	83 f8 16             	cmp    $0x16,%eax
80104db8:	77 27                	ja     80104de1 <syscall+0x4f>
80104dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dbd:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104dc4:	85 c0                	test   %eax,%eax
80104dc6:	74 19                	je     80104de1 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dcb:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104dd2:	ff d0                	call   *%eax
80104dd4:	89 c2                	mov    %eax,%edx
80104dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd9:	8b 40 18             	mov    0x18(%eax),%eax
80104ddc:	89 50 1c             	mov    %edx,0x1c(%eax)
80104ddf:	eb 2c                	jmp    80104e0d <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de4:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dea:	8b 40 10             	mov    0x10(%eax),%eax
80104ded:	ff 75 f0             	push   -0x10(%ebp)
80104df0:	52                   	push   %edx
80104df1:	50                   	push   %eax
80104df2:	68 22 a4 10 80       	push   $0x8010a422
80104df7:	e8 f8 b5 ff ff       	call   801003f4 <cprintf>
80104dfc:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e02:	8b 40 18             	mov    0x18(%eax),%eax
80104e05:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104e0c:	90                   	nop
80104e0d:	90                   	nop
80104e0e:	c9                   	leave
80104e0f:	c3                   	ret

80104e10 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104e16:	83 ec 08             	sub    $0x8,%esp
80104e19:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e1c:	50                   	push   %eax
80104e1d:	ff 75 08             	push   0x8(%ebp)
80104e20:	e8 a1 fe ff ff       	call   80104cc6 <argint>
80104e25:	83 c4 10             	add    $0x10,%esp
80104e28:	85 c0                	test   %eax,%eax
80104e2a:	79 07                	jns    80104e33 <argfd+0x23>
    return -1;
80104e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e31:	eb 4f                	jmp    80104e82 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e36:	85 c0                	test   %eax,%eax
80104e38:	78 20                	js     80104e5a <argfd+0x4a>
80104e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e3d:	83 f8 0f             	cmp    $0xf,%eax
80104e40:	7f 18                	jg     80104e5a <argfd+0x4a>
80104e42:	e8 e9 eb ff ff       	call   80103a30 <myproc>
80104e47:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e4a:	83 c2 08             	add    $0x8,%edx
80104e4d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e58:	75 07                	jne    80104e61 <argfd+0x51>
    return -1;
80104e5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e5f:	eb 21                	jmp    80104e82 <argfd+0x72>
  if(pfd)
80104e61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e65:	74 08                	je     80104e6f <argfd+0x5f>
    *pfd = fd;
80104e67:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e6d:	89 10                	mov    %edx,(%eax)
  if(pf)
80104e6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e73:	74 08                	je     80104e7d <argfd+0x6d>
    *pf = f;
80104e75:	8b 45 10             	mov    0x10(%ebp),%eax
80104e78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e7b:	89 10                	mov    %edx,(%eax)
  return 0;
80104e7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e82:	c9                   	leave
80104e83:	c3                   	ret

80104e84 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104e84:	55                   	push   %ebp
80104e85:	89 e5                	mov    %esp,%ebp
80104e87:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104e8a:	e8 a1 eb ff ff       	call   80103a30 <myproc>
80104e8f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104e92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e99:	eb 2a                	jmp    80104ec5 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ea1:	83 c2 08             	add    $0x8,%edx
80104ea4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ea8:	85 c0                	test   %eax,%eax
80104eaa:	75 15                	jne    80104ec1 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eaf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eb2:	8d 4a 08             	lea    0x8(%edx),%ecx
80104eb5:	8b 55 08             	mov    0x8(%ebp),%edx
80104eb8:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebf:	eb 0f                	jmp    80104ed0 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104ec1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ec5:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104ec9:	7e d0                	jle    80104e9b <fdalloc+0x17>
    }
  }
  return -1;
80104ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ed0:	c9                   	leave
80104ed1:	c3                   	ret

80104ed2 <sys_dup>:

int
sys_dup(void)
{
80104ed2:	55                   	push   %ebp
80104ed3:	89 e5                	mov    %esp,%ebp
80104ed5:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104ed8:	83 ec 04             	sub    $0x4,%esp
80104edb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ede:	50                   	push   %eax
80104edf:	6a 00                	push   $0x0
80104ee1:	6a 00                	push   $0x0
80104ee3:	e8 28 ff ff ff       	call   80104e10 <argfd>
80104ee8:	83 c4 10             	add    $0x10,%esp
80104eeb:	85 c0                	test   %eax,%eax
80104eed:	79 07                	jns    80104ef6 <sys_dup+0x24>
    return -1;
80104eef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ef4:	eb 31                	jmp    80104f27 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef9:	83 ec 0c             	sub    $0xc,%esp
80104efc:	50                   	push   %eax
80104efd:	e8 82 ff ff ff       	call   80104e84 <fdalloc>
80104f02:	83 c4 10             	add    $0x10,%esp
80104f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f0c:	79 07                	jns    80104f15 <sys_dup+0x43>
    return -1;
80104f0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f13:	eb 12                	jmp    80104f27 <sys_dup+0x55>
  filedup(f);
80104f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f18:	83 ec 0c             	sub    $0xc,%esp
80104f1b:	50                   	push   %eax
80104f1c:	e8 33 c1 ff ff       	call   80101054 <filedup>
80104f21:	83 c4 10             	add    $0x10,%esp
  return fd;
80104f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f27:	c9                   	leave
80104f28:	c3                   	ret

80104f29 <sys_read>:

int
sys_read(void)
{
80104f29:	55                   	push   %ebp
80104f2a:	89 e5                	mov    %esp,%ebp
80104f2c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f2f:	83 ec 04             	sub    $0x4,%esp
80104f32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f35:	50                   	push   %eax
80104f36:	6a 00                	push   $0x0
80104f38:	6a 00                	push   $0x0
80104f3a:	e8 d1 fe ff ff       	call   80104e10 <argfd>
80104f3f:	83 c4 10             	add    $0x10,%esp
80104f42:	85 c0                	test   %eax,%eax
80104f44:	78 2e                	js     80104f74 <sys_read+0x4b>
80104f46:	83 ec 08             	sub    $0x8,%esp
80104f49:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f4c:	50                   	push   %eax
80104f4d:	6a 02                	push   $0x2
80104f4f:	e8 72 fd ff ff       	call   80104cc6 <argint>
80104f54:	83 c4 10             	add    $0x10,%esp
80104f57:	85 c0                	test   %eax,%eax
80104f59:	78 19                	js     80104f74 <sys_read+0x4b>
80104f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f5e:	83 ec 04             	sub    $0x4,%esp
80104f61:	50                   	push   %eax
80104f62:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f65:	50                   	push   %eax
80104f66:	6a 01                	push   $0x1
80104f68:	e8 86 fd ff ff       	call   80104cf3 <argptr>
80104f6d:	83 c4 10             	add    $0x10,%esp
80104f70:	85 c0                	test   %eax,%eax
80104f72:	79 07                	jns    80104f7b <sys_read+0x52>
    return -1;
80104f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f79:	eb 17                	jmp    80104f92 <sys_read+0x69>
  return fileread(f, p, n);
80104f7b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f7e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f84:	83 ec 04             	sub    $0x4,%esp
80104f87:	51                   	push   %ecx
80104f88:	52                   	push   %edx
80104f89:	50                   	push   %eax
80104f8a:	e8 55 c2 ff ff       	call   801011e4 <fileread>
80104f8f:	83 c4 10             	add    $0x10,%esp
}
80104f92:	c9                   	leave
80104f93:	c3                   	ret

80104f94 <sys_write>:

int
sys_write(void)
{
80104f94:	55                   	push   %ebp
80104f95:	89 e5                	mov    %esp,%ebp
80104f97:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f9a:	83 ec 04             	sub    $0x4,%esp
80104f9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fa0:	50                   	push   %eax
80104fa1:	6a 00                	push   $0x0
80104fa3:	6a 00                	push   $0x0
80104fa5:	e8 66 fe ff ff       	call   80104e10 <argfd>
80104faa:	83 c4 10             	add    $0x10,%esp
80104fad:	85 c0                	test   %eax,%eax
80104faf:	78 2e                	js     80104fdf <sys_write+0x4b>
80104fb1:	83 ec 08             	sub    $0x8,%esp
80104fb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fb7:	50                   	push   %eax
80104fb8:	6a 02                	push   $0x2
80104fba:	e8 07 fd ff ff       	call   80104cc6 <argint>
80104fbf:	83 c4 10             	add    $0x10,%esp
80104fc2:	85 c0                	test   %eax,%eax
80104fc4:	78 19                	js     80104fdf <sys_write+0x4b>
80104fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc9:	83 ec 04             	sub    $0x4,%esp
80104fcc:	50                   	push   %eax
80104fcd:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fd0:	50                   	push   %eax
80104fd1:	6a 01                	push   $0x1
80104fd3:	e8 1b fd ff ff       	call   80104cf3 <argptr>
80104fd8:	83 c4 10             	add    $0x10,%esp
80104fdb:	85 c0                	test   %eax,%eax
80104fdd:	79 07                	jns    80104fe6 <sys_write+0x52>
    return -1;
80104fdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fe4:	eb 17                	jmp    80104ffd <sys_write+0x69>
  return filewrite(f, p, n);
80104fe6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104fe9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fef:	83 ec 04             	sub    $0x4,%esp
80104ff2:	51                   	push   %ecx
80104ff3:	52                   	push   %edx
80104ff4:	50                   	push   %eax
80104ff5:	e8 a2 c2 ff ff       	call   8010129c <filewrite>
80104ffa:	83 c4 10             	add    $0x10,%esp
}
80104ffd:	c9                   	leave
80104ffe:	c3                   	ret

80104fff <sys_close>:

int
sys_close(void)
{
80104fff:	55                   	push   %ebp
80105000:	89 e5                	mov    %esp,%ebp
80105002:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105005:	83 ec 04             	sub    $0x4,%esp
80105008:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010500b:	50                   	push   %eax
8010500c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010500f:	50                   	push   %eax
80105010:	6a 00                	push   $0x0
80105012:	e8 f9 fd ff ff       	call   80104e10 <argfd>
80105017:	83 c4 10             	add    $0x10,%esp
8010501a:	85 c0                	test   %eax,%eax
8010501c:	79 07                	jns    80105025 <sys_close+0x26>
    return -1;
8010501e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105023:	eb 27                	jmp    8010504c <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105025:	e8 06 ea ff ff       	call   80103a30 <myproc>
8010502a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010502d:	83 c2 08             	add    $0x8,%edx
80105030:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105037:	00 
  fileclose(f);
80105038:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010503b:	83 ec 0c             	sub    $0xc,%esp
8010503e:	50                   	push   %eax
8010503f:	e8 61 c0 ff ff       	call   801010a5 <fileclose>
80105044:	83 c4 10             	add    $0x10,%esp
  return 0;
80105047:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010504c:	c9                   	leave
8010504d:	c3                   	ret

8010504e <sys_fstat>:

int
sys_fstat(void)
{
8010504e:	55                   	push   %ebp
8010504f:	89 e5                	mov    %esp,%ebp
80105051:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105054:	83 ec 04             	sub    $0x4,%esp
80105057:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010505a:	50                   	push   %eax
8010505b:	6a 00                	push   $0x0
8010505d:	6a 00                	push   $0x0
8010505f:	e8 ac fd ff ff       	call   80104e10 <argfd>
80105064:	83 c4 10             	add    $0x10,%esp
80105067:	85 c0                	test   %eax,%eax
80105069:	78 17                	js     80105082 <sys_fstat+0x34>
8010506b:	83 ec 04             	sub    $0x4,%esp
8010506e:	6a 14                	push   $0x14
80105070:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105073:	50                   	push   %eax
80105074:	6a 01                	push   $0x1
80105076:	e8 78 fc ff ff       	call   80104cf3 <argptr>
8010507b:	83 c4 10             	add    $0x10,%esp
8010507e:	85 c0                	test   %eax,%eax
80105080:	79 07                	jns    80105089 <sys_fstat+0x3b>
    return -1;
80105082:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105087:	eb 13                	jmp    8010509c <sys_fstat+0x4e>
  return filestat(f, st);
80105089:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010508c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010508f:	83 ec 08             	sub    $0x8,%esp
80105092:	52                   	push   %edx
80105093:	50                   	push   %eax
80105094:	e8 f4 c0 ff ff       	call   8010118d <filestat>
80105099:	83 c4 10             	add    $0x10,%esp
}
8010509c:	c9                   	leave
8010509d:	c3                   	ret

8010509e <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010509e:	55                   	push   %ebp
8010509f:	89 e5                	mov    %esp,%ebp
801050a1:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801050a4:	83 ec 08             	sub    $0x8,%esp
801050a7:	8d 45 d8             	lea    -0x28(%ebp),%eax
801050aa:	50                   	push   %eax
801050ab:	6a 00                	push   $0x0
801050ad:	e8 a9 fc ff ff       	call   80104d5b <argstr>
801050b2:	83 c4 10             	add    $0x10,%esp
801050b5:	85 c0                	test   %eax,%eax
801050b7:	78 15                	js     801050ce <sys_link+0x30>
801050b9:	83 ec 08             	sub    $0x8,%esp
801050bc:	8d 45 dc             	lea    -0x24(%ebp),%eax
801050bf:	50                   	push   %eax
801050c0:	6a 01                	push   $0x1
801050c2:	e8 94 fc ff ff       	call   80104d5b <argstr>
801050c7:	83 c4 10             	add    $0x10,%esp
801050ca:	85 c0                	test   %eax,%eax
801050cc:	79 0a                	jns    801050d8 <sys_link+0x3a>
    return -1;
801050ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d3:	e9 68 01 00 00       	jmp    80105240 <sys_link+0x1a2>

  begin_op();
801050d8:	e8 61 df ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
801050dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050e0:	83 ec 0c             	sub    $0xc,%esp
801050e3:	50                   	push   %eax
801050e4:	e8 3c d4 ff ff       	call   80102525 <namei>
801050e9:	83 c4 10             	add    $0x10,%esp
801050ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050f3:	75 0f                	jne    80105104 <sys_link+0x66>
    end_op();
801050f5:	e8 d0 df ff ff       	call   801030ca <end_op>
    return -1;
801050fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ff:	e9 3c 01 00 00       	jmp    80105240 <sys_link+0x1a2>
  }

  ilock(ip);
80105104:	83 ec 0c             	sub    $0xc,%esp
80105107:	ff 75 f4             	push   -0xc(%ebp)
8010510a:	e8 e3 c8 ff ff       	call   801019f2 <ilock>
8010510f:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105112:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105115:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105119:	66 83 f8 01          	cmp    $0x1,%ax
8010511d:	75 1d                	jne    8010513c <sys_link+0x9e>
    iunlockput(ip);
8010511f:	83 ec 0c             	sub    $0xc,%esp
80105122:	ff 75 f4             	push   -0xc(%ebp)
80105125:	e8 f9 ca ff ff       	call   80101c23 <iunlockput>
8010512a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010512d:	e8 98 df ff ff       	call   801030ca <end_op>
    return -1;
80105132:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105137:	e9 04 01 00 00       	jmp    80105240 <sys_link+0x1a2>
  }

  ip->nlink++;
8010513c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105143:	83 c0 01             	add    $0x1,%eax
80105146:	89 c2                	mov    %eax,%edx
80105148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514b:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010514f:	83 ec 0c             	sub    $0xc,%esp
80105152:	ff 75 f4             	push   -0xc(%ebp)
80105155:	e8 bb c6 ff ff       	call   80101815 <iupdate>
8010515a:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010515d:	83 ec 0c             	sub    $0xc,%esp
80105160:	ff 75 f4             	push   -0xc(%ebp)
80105163:	e8 9d c9 ff ff       	call   80101b05 <iunlock>
80105168:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010516b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010516e:	83 ec 08             	sub    $0x8,%esp
80105171:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105174:	52                   	push   %edx
80105175:	50                   	push   %eax
80105176:	e8 c6 d3 ff ff       	call   80102541 <nameiparent>
8010517b:	83 c4 10             	add    $0x10,%esp
8010517e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105181:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105185:	74 71                	je     801051f8 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105187:	83 ec 0c             	sub    $0xc,%esp
8010518a:	ff 75 f0             	push   -0x10(%ebp)
8010518d:	e8 60 c8 ff ff       	call   801019f2 <ilock>
80105192:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105195:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105198:	8b 10                	mov    (%eax),%edx
8010519a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519d:	8b 00                	mov    (%eax),%eax
8010519f:	39 c2                	cmp    %eax,%edx
801051a1:	75 1d                	jne    801051c0 <sys_link+0x122>
801051a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a6:	8b 40 04             	mov    0x4(%eax),%eax
801051a9:	83 ec 04             	sub    $0x4,%esp
801051ac:	50                   	push   %eax
801051ad:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801051b0:	50                   	push   %eax
801051b1:	ff 75 f0             	push   -0x10(%ebp)
801051b4:	e8 d5 d0 ff ff       	call   8010228e <dirlink>
801051b9:	83 c4 10             	add    $0x10,%esp
801051bc:	85 c0                	test   %eax,%eax
801051be:	79 10                	jns    801051d0 <sys_link+0x132>
    iunlockput(dp);
801051c0:	83 ec 0c             	sub    $0xc,%esp
801051c3:	ff 75 f0             	push   -0x10(%ebp)
801051c6:	e8 58 ca ff ff       	call   80101c23 <iunlockput>
801051cb:	83 c4 10             	add    $0x10,%esp
    goto bad;
801051ce:	eb 29                	jmp    801051f9 <sys_link+0x15b>
  }
  iunlockput(dp);
801051d0:	83 ec 0c             	sub    $0xc,%esp
801051d3:	ff 75 f0             	push   -0x10(%ebp)
801051d6:	e8 48 ca ff ff       	call   80101c23 <iunlockput>
801051db:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801051de:	83 ec 0c             	sub    $0xc,%esp
801051e1:	ff 75 f4             	push   -0xc(%ebp)
801051e4:	e8 6a c9 ff ff       	call   80101b53 <iput>
801051e9:	83 c4 10             	add    $0x10,%esp

  end_op();
801051ec:	e8 d9 de ff ff       	call   801030ca <end_op>

  return 0;
801051f1:	b8 00 00 00 00       	mov    $0x0,%eax
801051f6:	eb 48                	jmp    80105240 <sys_link+0x1a2>
    goto bad;
801051f8:	90                   	nop

bad:
  ilock(ip);
801051f9:	83 ec 0c             	sub    $0xc,%esp
801051fc:	ff 75 f4             	push   -0xc(%ebp)
801051ff:	e8 ee c7 ff ff       	call   801019f2 <ilock>
80105204:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010520e:	83 e8 01             	sub    $0x1,%eax
80105211:	89 c2                	mov    %eax,%edx
80105213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105216:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010521a:	83 ec 0c             	sub    $0xc,%esp
8010521d:	ff 75 f4             	push   -0xc(%ebp)
80105220:	e8 f0 c5 ff ff       	call   80101815 <iupdate>
80105225:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105228:	83 ec 0c             	sub    $0xc,%esp
8010522b:	ff 75 f4             	push   -0xc(%ebp)
8010522e:	e8 f0 c9 ff ff       	call   80101c23 <iunlockput>
80105233:	83 c4 10             	add    $0x10,%esp
  end_op();
80105236:	e8 8f de ff ff       	call   801030ca <end_op>
  return -1;
8010523b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105240:	c9                   	leave
80105241:	c3                   	ret

80105242 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105242:	55                   	push   %ebp
80105243:	89 e5                	mov    %esp,%ebp
80105245:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105248:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010524f:	eb 40                	jmp    80105291 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105254:	6a 10                	push   $0x10
80105256:	50                   	push   %eax
80105257:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010525a:	50                   	push   %eax
8010525b:	ff 75 08             	push   0x8(%ebp)
8010525e:	e8 7b cc ff ff       	call   80101ede <readi>
80105263:	83 c4 10             	add    $0x10,%esp
80105266:	83 f8 10             	cmp    $0x10,%eax
80105269:	74 0d                	je     80105278 <isdirempty+0x36>
      panic("isdirempty: readi");
8010526b:	83 ec 0c             	sub    $0xc,%esp
8010526e:	68 3e a4 10 80       	push   $0x8010a43e
80105273:	e8 31 b3 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105278:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010527c:	66 85 c0             	test   %ax,%ax
8010527f:	74 07                	je     80105288 <isdirempty+0x46>
      return 0;
80105281:	b8 00 00 00 00       	mov    $0x0,%eax
80105286:	eb 1b                	jmp    801052a3 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528b:	83 c0 10             	add    $0x10,%eax
8010528e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105291:	8b 45 08             	mov    0x8(%ebp),%eax
80105294:	8b 40 58             	mov    0x58(%eax),%eax
80105297:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010529a:	39 c2                	cmp    %eax,%edx
8010529c:	72 b3                	jb     80105251 <isdirempty+0xf>
  }
  return 1;
8010529e:	b8 01 00 00 00       	mov    $0x1,%eax
}
801052a3:	c9                   	leave
801052a4:	c3                   	ret

801052a5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801052a5:	55                   	push   %ebp
801052a6:	89 e5                	mov    %esp,%ebp
801052a8:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801052ab:	83 ec 08             	sub    $0x8,%esp
801052ae:	8d 45 cc             	lea    -0x34(%ebp),%eax
801052b1:	50                   	push   %eax
801052b2:	6a 00                	push   $0x0
801052b4:	e8 a2 fa ff ff       	call   80104d5b <argstr>
801052b9:	83 c4 10             	add    $0x10,%esp
801052bc:	85 c0                	test   %eax,%eax
801052be:	79 0a                	jns    801052ca <sys_unlink+0x25>
    return -1;
801052c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052c5:	e9 bf 01 00 00       	jmp    80105489 <sys_unlink+0x1e4>

  begin_op();
801052ca:	e8 6f dd ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052d2:	83 ec 08             	sub    $0x8,%esp
801052d5:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801052d8:	52                   	push   %edx
801052d9:	50                   	push   %eax
801052da:	e8 62 d2 ff ff       	call   80102541 <nameiparent>
801052df:	83 c4 10             	add    $0x10,%esp
801052e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052e9:	75 0f                	jne    801052fa <sys_unlink+0x55>
    end_op();
801052eb:	e8 da dd ff ff       	call   801030ca <end_op>
    return -1;
801052f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052f5:	e9 8f 01 00 00       	jmp    80105489 <sys_unlink+0x1e4>
  }

  ilock(dp);
801052fa:	83 ec 0c             	sub    $0xc,%esp
801052fd:	ff 75 f4             	push   -0xc(%ebp)
80105300:	e8 ed c6 ff ff       	call   801019f2 <ilock>
80105305:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105308:	83 ec 08             	sub    $0x8,%esp
8010530b:	68 50 a4 10 80       	push   $0x8010a450
80105310:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105313:	50                   	push   %eax
80105314:	e8 a0 ce ff ff       	call   801021b9 <namecmp>
80105319:	83 c4 10             	add    $0x10,%esp
8010531c:	85 c0                	test   %eax,%eax
8010531e:	0f 84 49 01 00 00    	je     8010546d <sys_unlink+0x1c8>
80105324:	83 ec 08             	sub    $0x8,%esp
80105327:	68 52 a4 10 80       	push   $0x8010a452
8010532c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010532f:	50                   	push   %eax
80105330:	e8 84 ce ff ff       	call   801021b9 <namecmp>
80105335:	83 c4 10             	add    $0x10,%esp
80105338:	85 c0                	test   %eax,%eax
8010533a:	0f 84 2d 01 00 00    	je     8010546d <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105340:	83 ec 04             	sub    $0x4,%esp
80105343:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105346:	50                   	push   %eax
80105347:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010534a:	50                   	push   %eax
8010534b:	ff 75 f4             	push   -0xc(%ebp)
8010534e:	e8 81 ce ff ff       	call   801021d4 <dirlookup>
80105353:	83 c4 10             	add    $0x10,%esp
80105356:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105359:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010535d:	0f 84 0d 01 00 00    	je     80105470 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105363:	83 ec 0c             	sub    $0xc,%esp
80105366:	ff 75 f0             	push   -0x10(%ebp)
80105369:	e8 84 c6 ff ff       	call   801019f2 <ilock>
8010536e:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105374:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105378:	66 85 c0             	test   %ax,%ax
8010537b:	7f 0d                	jg     8010538a <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010537d:	83 ec 0c             	sub    $0xc,%esp
80105380:	68 55 a4 10 80       	push   $0x8010a455
80105385:	e8 1f b2 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010538a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010538d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105391:	66 83 f8 01          	cmp    $0x1,%ax
80105395:	75 25                	jne    801053bc <sys_unlink+0x117>
80105397:	83 ec 0c             	sub    $0xc,%esp
8010539a:	ff 75 f0             	push   -0x10(%ebp)
8010539d:	e8 a0 fe ff ff       	call   80105242 <isdirempty>
801053a2:	83 c4 10             	add    $0x10,%esp
801053a5:	85 c0                	test   %eax,%eax
801053a7:	75 13                	jne    801053bc <sys_unlink+0x117>
    iunlockput(ip);
801053a9:	83 ec 0c             	sub    $0xc,%esp
801053ac:	ff 75 f0             	push   -0x10(%ebp)
801053af:	e8 6f c8 ff ff       	call   80101c23 <iunlockput>
801053b4:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053b7:	e9 b5 00 00 00       	jmp    80105471 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801053bc:	83 ec 04             	sub    $0x4,%esp
801053bf:	6a 10                	push   $0x10
801053c1:	6a 00                	push   $0x0
801053c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053c6:	50                   	push   %eax
801053c7:	e8 cf f5 ff ff       	call   8010499b <memset>
801053cc:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053cf:	8b 45 c8             	mov    -0x38(%ebp),%eax
801053d2:	6a 10                	push   $0x10
801053d4:	50                   	push   %eax
801053d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053d8:	50                   	push   %eax
801053d9:	ff 75 f4             	push   -0xc(%ebp)
801053dc:	e8 52 cc ff ff       	call   80102033 <writei>
801053e1:	83 c4 10             	add    $0x10,%esp
801053e4:	83 f8 10             	cmp    $0x10,%eax
801053e7:	74 0d                	je     801053f6 <sys_unlink+0x151>
    panic("unlink: writei");
801053e9:	83 ec 0c             	sub    $0xc,%esp
801053ec:	68 67 a4 10 80       	push   $0x8010a467
801053f1:	e8 b3 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801053f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801053fd:	66 83 f8 01          	cmp    $0x1,%ax
80105401:	75 21                	jne    80105424 <sys_unlink+0x17f>
    dp->nlink--;
80105403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105406:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010540a:	83 e8 01             	sub    $0x1,%eax
8010540d:	89 c2                	mov    %eax,%edx
8010540f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105412:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105416:	83 ec 0c             	sub    $0xc,%esp
80105419:	ff 75 f4             	push   -0xc(%ebp)
8010541c:	e8 f4 c3 ff ff       	call   80101815 <iupdate>
80105421:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105424:	83 ec 0c             	sub    $0xc,%esp
80105427:	ff 75 f4             	push   -0xc(%ebp)
8010542a:	e8 f4 c7 ff ff       	call   80101c23 <iunlockput>
8010542f:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105432:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105435:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105439:	83 e8 01             	sub    $0x1,%eax
8010543c:	89 c2                	mov    %eax,%edx
8010543e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105441:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105445:	83 ec 0c             	sub    $0xc,%esp
80105448:	ff 75 f0             	push   -0x10(%ebp)
8010544b:	e8 c5 c3 ff ff       	call   80101815 <iupdate>
80105450:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105453:	83 ec 0c             	sub    $0xc,%esp
80105456:	ff 75 f0             	push   -0x10(%ebp)
80105459:	e8 c5 c7 ff ff       	call   80101c23 <iunlockput>
8010545e:	83 c4 10             	add    $0x10,%esp

  end_op();
80105461:	e8 64 dc ff ff       	call   801030ca <end_op>

  return 0;
80105466:	b8 00 00 00 00       	mov    $0x0,%eax
8010546b:	eb 1c                	jmp    80105489 <sys_unlink+0x1e4>
    goto bad;
8010546d:	90                   	nop
8010546e:	eb 01                	jmp    80105471 <sys_unlink+0x1cc>
    goto bad;
80105470:	90                   	nop

bad:
  iunlockput(dp);
80105471:	83 ec 0c             	sub    $0xc,%esp
80105474:	ff 75 f4             	push   -0xc(%ebp)
80105477:	e8 a7 c7 ff ff       	call   80101c23 <iunlockput>
8010547c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010547f:	e8 46 dc ff ff       	call   801030ca <end_op>
  return -1;
80105484:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105489:	c9                   	leave
8010548a:	c3                   	ret

8010548b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010548b:	55                   	push   %ebp
8010548c:	89 e5                	mov    %esp,%ebp
8010548e:	83 ec 38             	sub    $0x38,%esp
80105491:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105494:	8b 55 10             	mov    0x10(%ebp),%edx
80105497:	8b 45 14             	mov    0x14(%ebp),%eax
8010549a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010549e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801054a2:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801054a6:	83 ec 08             	sub    $0x8,%esp
801054a9:	8d 45 de             	lea    -0x22(%ebp),%eax
801054ac:	50                   	push   %eax
801054ad:	ff 75 08             	push   0x8(%ebp)
801054b0:	e8 8c d0 ff ff       	call   80102541 <nameiparent>
801054b5:	83 c4 10             	add    $0x10,%esp
801054b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054bf:	75 0a                	jne    801054cb <create+0x40>
    return 0;
801054c1:	b8 00 00 00 00       	mov    $0x0,%eax
801054c6:	e9 90 01 00 00       	jmp    8010565b <create+0x1d0>
  ilock(dp);
801054cb:	83 ec 0c             	sub    $0xc,%esp
801054ce:	ff 75 f4             	push   -0xc(%ebp)
801054d1:	e8 1c c5 ff ff       	call   801019f2 <ilock>
801054d6:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801054d9:	83 ec 04             	sub    $0x4,%esp
801054dc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054df:	50                   	push   %eax
801054e0:	8d 45 de             	lea    -0x22(%ebp),%eax
801054e3:	50                   	push   %eax
801054e4:	ff 75 f4             	push   -0xc(%ebp)
801054e7:	e8 e8 cc ff ff       	call   801021d4 <dirlookup>
801054ec:	83 c4 10             	add    $0x10,%esp
801054ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054f6:	74 50                	je     80105548 <create+0xbd>
    iunlockput(dp);
801054f8:	83 ec 0c             	sub    $0xc,%esp
801054fb:	ff 75 f4             	push   -0xc(%ebp)
801054fe:	e8 20 c7 ff ff       	call   80101c23 <iunlockput>
80105503:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105506:	83 ec 0c             	sub    $0xc,%esp
80105509:	ff 75 f0             	push   -0x10(%ebp)
8010550c:	e8 e1 c4 ff ff       	call   801019f2 <ilock>
80105511:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105514:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105519:	75 15                	jne    80105530 <create+0xa5>
8010551b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010551e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105522:	66 83 f8 02          	cmp    $0x2,%ax
80105526:	75 08                	jne    80105530 <create+0xa5>
      return ip;
80105528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010552b:	e9 2b 01 00 00       	jmp    8010565b <create+0x1d0>
    iunlockput(ip);
80105530:	83 ec 0c             	sub    $0xc,%esp
80105533:	ff 75 f0             	push   -0x10(%ebp)
80105536:	e8 e8 c6 ff ff       	call   80101c23 <iunlockput>
8010553b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010553e:	b8 00 00 00 00       	mov    $0x0,%eax
80105543:	e9 13 01 00 00       	jmp    8010565b <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105548:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010554c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554f:	8b 00                	mov    (%eax),%eax
80105551:	83 ec 08             	sub    $0x8,%esp
80105554:	52                   	push   %edx
80105555:	50                   	push   %eax
80105556:	e8 e4 c1 ff ff       	call   8010173f <ialloc>
8010555b:	83 c4 10             	add    $0x10,%esp
8010555e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105561:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105565:	75 0d                	jne    80105574 <create+0xe9>
    panic("create: ialloc");
80105567:	83 ec 0c             	sub    $0xc,%esp
8010556a:	68 76 a4 10 80       	push   $0x8010a476
8010556f:	e8 35 b0 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105574:	83 ec 0c             	sub    $0xc,%esp
80105577:	ff 75 f0             	push   -0x10(%ebp)
8010557a:	e8 73 c4 ff ff       	call   801019f2 <ilock>
8010557f:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105582:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105585:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105589:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010558d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105590:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105594:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010559b:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801055a1:	83 ec 0c             	sub    $0xc,%esp
801055a4:	ff 75 f0             	push   -0x10(%ebp)
801055a7:	e8 69 c2 ff ff       	call   80101815 <iupdate>
801055ac:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801055af:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801055b4:	75 6a                	jne    80105620 <create+0x195>
    dp->nlink++;  // for ".."
801055b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b9:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055bd:	83 c0 01             	add    $0x1,%eax
801055c0:	89 c2                	mov    %eax,%edx
801055c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c5:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801055c9:	83 ec 0c             	sub    $0xc,%esp
801055cc:	ff 75 f4             	push   -0xc(%ebp)
801055cf:	e8 41 c2 ff ff       	call   80101815 <iupdate>
801055d4:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801055d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055da:	8b 40 04             	mov    0x4(%eax),%eax
801055dd:	83 ec 04             	sub    $0x4,%esp
801055e0:	50                   	push   %eax
801055e1:	68 50 a4 10 80       	push   $0x8010a450
801055e6:	ff 75 f0             	push   -0x10(%ebp)
801055e9:	e8 a0 cc ff ff       	call   8010228e <dirlink>
801055ee:	83 c4 10             	add    $0x10,%esp
801055f1:	85 c0                	test   %eax,%eax
801055f3:	78 1e                	js     80105613 <create+0x188>
801055f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f8:	8b 40 04             	mov    0x4(%eax),%eax
801055fb:	83 ec 04             	sub    $0x4,%esp
801055fe:	50                   	push   %eax
801055ff:	68 52 a4 10 80       	push   $0x8010a452
80105604:	ff 75 f0             	push   -0x10(%ebp)
80105607:	e8 82 cc ff ff       	call   8010228e <dirlink>
8010560c:	83 c4 10             	add    $0x10,%esp
8010560f:	85 c0                	test   %eax,%eax
80105611:	79 0d                	jns    80105620 <create+0x195>
      panic("create dots");
80105613:	83 ec 0c             	sub    $0xc,%esp
80105616:	68 85 a4 10 80       	push   $0x8010a485
8010561b:	e8 89 af ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105620:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105623:	8b 40 04             	mov    0x4(%eax),%eax
80105626:	83 ec 04             	sub    $0x4,%esp
80105629:	50                   	push   %eax
8010562a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010562d:	50                   	push   %eax
8010562e:	ff 75 f4             	push   -0xc(%ebp)
80105631:	e8 58 cc ff ff       	call   8010228e <dirlink>
80105636:	83 c4 10             	add    $0x10,%esp
80105639:	85 c0                	test   %eax,%eax
8010563b:	79 0d                	jns    8010564a <create+0x1bf>
    panic("create: dirlink");
8010563d:	83 ec 0c             	sub    $0xc,%esp
80105640:	68 91 a4 10 80       	push   $0x8010a491
80105645:	e8 5f af ff ff       	call   801005a9 <panic>

  iunlockput(dp);
8010564a:	83 ec 0c             	sub    $0xc,%esp
8010564d:	ff 75 f4             	push   -0xc(%ebp)
80105650:	e8 ce c5 ff ff       	call   80101c23 <iunlockput>
80105655:	83 c4 10             	add    $0x10,%esp

  return ip;
80105658:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010565b:	c9                   	leave
8010565c:	c3                   	ret

8010565d <sys_open>:

int
sys_open(void)
{
8010565d:	55                   	push   %ebp
8010565e:	89 e5                	mov    %esp,%ebp
80105660:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105663:	83 ec 08             	sub    $0x8,%esp
80105666:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105669:	50                   	push   %eax
8010566a:	6a 00                	push   $0x0
8010566c:	e8 ea f6 ff ff       	call   80104d5b <argstr>
80105671:	83 c4 10             	add    $0x10,%esp
80105674:	85 c0                	test   %eax,%eax
80105676:	78 15                	js     8010568d <sys_open+0x30>
80105678:	83 ec 08             	sub    $0x8,%esp
8010567b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010567e:	50                   	push   %eax
8010567f:	6a 01                	push   $0x1
80105681:	e8 40 f6 ff ff       	call   80104cc6 <argint>
80105686:	83 c4 10             	add    $0x10,%esp
80105689:	85 c0                	test   %eax,%eax
8010568b:	79 0a                	jns    80105697 <sys_open+0x3a>
    return -1;
8010568d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105692:	e9 61 01 00 00       	jmp    801057f8 <sys_open+0x19b>

  begin_op();
80105697:	e8 a2 d9 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
8010569c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010569f:	25 00 02 00 00       	and    $0x200,%eax
801056a4:	85 c0                	test   %eax,%eax
801056a6:	74 2a                	je     801056d2 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801056a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056ab:	6a 00                	push   $0x0
801056ad:	6a 00                	push   $0x0
801056af:	6a 02                	push   $0x2
801056b1:	50                   	push   %eax
801056b2:	e8 d4 fd ff ff       	call   8010548b <create>
801056b7:	83 c4 10             	add    $0x10,%esp
801056ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801056bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056c1:	75 75                	jne    80105738 <sys_open+0xdb>
      end_op();
801056c3:	e8 02 da ff ff       	call   801030ca <end_op>
      return -1;
801056c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056cd:	e9 26 01 00 00       	jmp    801057f8 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801056d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056d5:	83 ec 0c             	sub    $0xc,%esp
801056d8:	50                   	push   %eax
801056d9:	e8 47 ce ff ff       	call   80102525 <namei>
801056de:	83 c4 10             	add    $0x10,%esp
801056e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056e8:	75 0f                	jne    801056f9 <sys_open+0x9c>
      end_op();
801056ea:	e8 db d9 ff ff       	call   801030ca <end_op>
      return -1;
801056ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f4:	e9 ff 00 00 00       	jmp    801057f8 <sys_open+0x19b>
    }
    ilock(ip);
801056f9:	83 ec 0c             	sub    $0xc,%esp
801056fc:	ff 75 f4             	push   -0xc(%ebp)
801056ff:	e8 ee c2 ff ff       	call   801019f2 <ilock>
80105704:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010570a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010570e:	66 83 f8 01          	cmp    $0x1,%ax
80105712:	75 24                	jne    80105738 <sys_open+0xdb>
80105714:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105717:	85 c0                	test   %eax,%eax
80105719:	74 1d                	je     80105738 <sys_open+0xdb>
      iunlockput(ip);
8010571b:	83 ec 0c             	sub    $0xc,%esp
8010571e:	ff 75 f4             	push   -0xc(%ebp)
80105721:	e8 fd c4 ff ff       	call   80101c23 <iunlockput>
80105726:	83 c4 10             	add    $0x10,%esp
      end_op();
80105729:	e8 9c d9 ff ff       	call   801030ca <end_op>
      return -1;
8010572e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105733:	e9 c0 00 00 00       	jmp    801057f8 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105738:	e8 aa b8 ff ff       	call   80100fe7 <filealloc>
8010573d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105740:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105744:	74 17                	je     8010575d <sys_open+0x100>
80105746:	83 ec 0c             	sub    $0xc,%esp
80105749:	ff 75 f0             	push   -0x10(%ebp)
8010574c:	e8 33 f7 ff ff       	call   80104e84 <fdalloc>
80105751:	83 c4 10             	add    $0x10,%esp
80105754:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105757:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010575b:	79 2e                	jns    8010578b <sys_open+0x12e>
    if(f)
8010575d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105761:	74 0e                	je     80105771 <sys_open+0x114>
      fileclose(f);
80105763:	83 ec 0c             	sub    $0xc,%esp
80105766:	ff 75 f0             	push   -0x10(%ebp)
80105769:	e8 37 b9 ff ff       	call   801010a5 <fileclose>
8010576e:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105771:	83 ec 0c             	sub    $0xc,%esp
80105774:	ff 75 f4             	push   -0xc(%ebp)
80105777:	e8 a7 c4 ff ff       	call   80101c23 <iunlockput>
8010577c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010577f:	e8 46 d9 ff ff       	call   801030ca <end_op>
    return -1;
80105784:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105789:	eb 6d                	jmp    801057f8 <sys_open+0x19b>
  }
  iunlock(ip);
8010578b:	83 ec 0c             	sub    $0xc,%esp
8010578e:	ff 75 f4             	push   -0xc(%ebp)
80105791:	e8 6f c3 ff ff       	call   80101b05 <iunlock>
80105796:	83 c4 10             	add    $0x10,%esp
  end_op();
80105799:	e8 2c d9 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
8010579e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a1:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801057a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057ad:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801057b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057b3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801057ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057bd:	83 e0 01             	and    $0x1,%eax
801057c0:	85 c0                	test   %eax,%eax
801057c2:	0f 94 c0             	sete   %al
801057c5:	89 c2                	mov    %eax,%edx
801057c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ca:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801057cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057d0:	83 e0 01             	and    $0x1,%eax
801057d3:	85 c0                	test   %eax,%eax
801057d5:	75 0a                	jne    801057e1 <sys_open+0x184>
801057d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057da:	83 e0 02             	and    $0x2,%eax
801057dd:	85 c0                	test   %eax,%eax
801057df:	74 07                	je     801057e8 <sys_open+0x18b>
801057e1:	b8 01 00 00 00       	mov    $0x1,%eax
801057e6:	eb 05                	jmp    801057ed <sys_open+0x190>
801057e8:	b8 00 00 00 00       	mov    $0x0,%eax
801057ed:	89 c2                	mov    %eax,%edx
801057ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f2:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801057f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801057f8:	c9                   	leave
801057f9:	c3                   	ret

801057fa <sys_mkdir>:

int
sys_mkdir(void)
{
801057fa:	55                   	push   %ebp
801057fb:	89 e5                	mov    %esp,%ebp
801057fd:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105800:	e8 39 d8 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105805:	83 ec 08             	sub    $0x8,%esp
80105808:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010580b:	50                   	push   %eax
8010580c:	6a 00                	push   $0x0
8010580e:	e8 48 f5 ff ff       	call   80104d5b <argstr>
80105813:	83 c4 10             	add    $0x10,%esp
80105816:	85 c0                	test   %eax,%eax
80105818:	78 1b                	js     80105835 <sys_mkdir+0x3b>
8010581a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581d:	6a 00                	push   $0x0
8010581f:	6a 00                	push   $0x0
80105821:	6a 01                	push   $0x1
80105823:	50                   	push   %eax
80105824:	e8 62 fc ff ff       	call   8010548b <create>
80105829:	83 c4 10             	add    $0x10,%esp
8010582c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010582f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105833:	75 0c                	jne    80105841 <sys_mkdir+0x47>
    end_op();
80105835:	e8 90 d8 ff ff       	call   801030ca <end_op>
    return -1;
8010583a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010583f:	eb 18                	jmp    80105859 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105841:	83 ec 0c             	sub    $0xc,%esp
80105844:	ff 75 f4             	push   -0xc(%ebp)
80105847:	e8 d7 c3 ff ff       	call   80101c23 <iunlockput>
8010584c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010584f:	e8 76 d8 ff ff       	call   801030ca <end_op>
  return 0;
80105854:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105859:	c9                   	leave
8010585a:	c3                   	ret

8010585b <sys_mknod>:

int
sys_mknod(void)
{
8010585b:	55                   	push   %ebp
8010585c:	89 e5                	mov    %esp,%ebp
8010585e:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105861:	e8 d8 d7 ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
80105866:	83 ec 08             	sub    $0x8,%esp
80105869:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010586c:	50                   	push   %eax
8010586d:	6a 00                	push   $0x0
8010586f:	e8 e7 f4 ff ff       	call   80104d5b <argstr>
80105874:	83 c4 10             	add    $0x10,%esp
80105877:	85 c0                	test   %eax,%eax
80105879:	78 4f                	js     801058ca <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010587b:	83 ec 08             	sub    $0x8,%esp
8010587e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105881:	50                   	push   %eax
80105882:	6a 01                	push   $0x1
80105884:	e8 3d f4 ff ff       	call   80104cc6 <argint>
80105889:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010588c:	85 c0                	test   %eax,%eax
8010588e:	78 3a                	js     801058ca <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105890:	83 ec 08             	sub    $0x8,%esp
80105893:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105896:	50                   	push   %eax
80105897:	6a 02                	push   $0x2
80105899:	e8 28 f4 ff ff       	call   80104cc6 <argint>
8010589e:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801058a1:	85 c0                	test   %eax,%eax
801058a3:	78 25                	js     801058ca <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
801058a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058a8:	0f bf c8             	movswl %ax,%ecx
801058ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801058ae:	0f bf d0             	movswl %ax,%edx
801058b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b4:	51                   	push   %ecx
801058b5:	52                   	push   %edx
801058b6:	6a 03                	push   $0x3
801058b8:	50                   	push   %eax
801058b9:	e8 cd fb ff ff       	call   8010548b <create>
801058be:	83 c4 10             	add    $0x10,%esp
801058c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801058c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c8:	75 0c                	jne    801058d6 <sys_mknod+0x7b>
    end_op();
801058ca:	e8 fb d7 ff ff       	call   801030ca <end_op>
    return -1;
801058cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d4:	eb 18                	jmp    801058ee <sys_mknod+0x93>
  }
  iunlockput(ip);
801058d6:	83 ec 0c             	sub    $0xc,%esp
801058d9:	ff 75 f4             	push   -0xc(%ebp)
801058dc:	e8 42 c3 ff ff       	call   80101c23 <iunlockput>
801058e1:	83 c4 10             	add    $0x10,%esp
  end_op();
801058e4:	e8 e1 d7 ff ff       	call   801030ca <end_op>
  return 0;
801058e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058ee:	c9                   	leave
801058ef:	c3                   	ret

801058f0 <sys_chdir>:

int
sys_chdir(void)
{
801058f0:	55                   	push   %ebp
801058f1:	89 e5                	mov    %esp,%ebp
801058f3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801058f6:	e8 35 e1 ff ff       	call   80103a30 <myproc>
801058fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801058fe:	e8 3b d7 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105903:	83 ec 08             	sub    $0x8,%esp
80105906:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105909:	50                   	push   %eax
8010590a:	6a 00                	push   $0x0
8010590c:	e8 4a f4 ff ff       	call   80104d5b <argstr>
80105911:	83 c4 10             	add    $0x10,%esp
80105914:	85 c0                	test   %eax,%eax
80105916:	78 18                	js     80105930 <sys_chdir+0x40>
80105918:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010591b:	83 ec 0c             	sub    $0xc,%esp
8010591e:	50                   	push   %eax
8010591f:	e8 01 cc ff ff       	call   80102525 <namei>
80105924:	83 c4 10             	add    $0x10,%esp
80105927:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010592a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010592e:	75 0c                	jne    8010593c <sys_chdir+0x4c>
    end_op();
80105930:	e8 95 d7 ff ff       	call   801030ca <end_op>
    return -1;
80105935:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010593a:	eb 68                	jmp    801059a4 <sys_chdir+0xb4>
  }
  ilock(ip);
8010593c:	83 ec 0c             	sub    $0xc,%esp
8010593f:	ff 75 f0             	push   -0x10(%ebp)
80105942:	e8 ab c0 ff ff       	call   801019f2 <ilock>
80105947:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010594a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105951:	66 83 f8 01          	cmp    $0x1,%ax
80105955:	74 1a                	je     80105971 <sys_chdir+0x81>
    iunlockput(ip);
80105957:	83 ec 0c             	sub    $0xc,%esp
8010595a:	ff 75 f0             	push   -0x10(%ebp)
8010595d:	e8 c1 c2 ff ff       	call   80101c23 <iunlockput>
80105962:	83 c4 10             	add    $0x10,%esp
    end_op();
80105965:	e8 60 d7 ff ff       	call   801030ca <end_op>
    return -1;
8010596a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596f:	eb 33                	jmp    801059a4 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105971:	83 ec 0c             	sub    $0xc,%esp
80105974:	ff 75 f0             	push   -0x10(%ebp)
80105977:	e8 89 c1 ff ff       	call   80101b05 <iunlock>
8010597c:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010597f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105982:	8b 40 68             	mov    0x68(%eax),%eax
80105985:	83 ec 0c             	sub    $0xc,%esp
80105988:	50                   	push   %eax
80105989:	e8 c5 c1 ff ff       	call   80101b53 <iput>
8010598e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105991:	e8 34 d7 ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
80105996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105999:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010599c:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010599f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a4:	c9                   	leave
801059a5:	c3                   	ret

801059a6 <sys_exec>:

int
sys_exec(void)
{
801059a6:	55                   	push   %ebp
801059a7:	89 e5                	mov    %esp,%ebp
801059a9:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801059af:	83 ec 08             	sub    $0x8,%esp
801059b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b5:	50                   	push   %eax
801059b6:	6a 00                	push   $0x0
801059b8:	e8 9e f3 ff ff       	call   80104d5b <argstr>
801059bd:	83 c4 10             	add    $0x10,%esp
801059c0:	85 c0                	test   %eax,%eax
801059c2:	78 18                	js     801059dc <sys_exec+0x36>
801059c4:	83 ec 08             	sub    $0x8,%esp
801059c7:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801059cd:	50                   	push   %eax
801059ce:	6a 01                	push   $0x1
801059d0:	e8 f1 f2 ff ff       	call   80104cc6 <argint>
801059d5:	83 c4 10             	add    $0x10,%esp
801059d8:	85 c0                	test   %eax,%eax
801059da:	79 0a                	jns    801059e6 <sys_exec+0x40>
    return -1;
801059dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e1:	e9 c6 00 00 00       	jmp    80105aac <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801059e6:	83 ec 04             	sub    $0x4,%esp
801059e9:	68 80 00 00 00       	push   $0x80
801059ee:	6a 00                	push   $0x0
801059f0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801059f6:	50                   	push   %eax
801059f7:	e8 9f ef ff ff       	call   8010499b <memset>
801059fc:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801059ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a09:	83 f8 1f             	cmp    $0x1f,%eax
80105a0c:	76 0a                	jbe    80105a18 <sys_exec+0x72>
      return -1;
80105a0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a13:	e9 94 00 00 00       	jmp    80105aac <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1b:	c1 e0 02             	shl    $0x2,%eax
80105a1e:	89 c2                	mov    %eax,%edx
80105a20:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105a26:	01 c2                	add    %eax,%edx
80105a28:	83 ec 08             	sub    $0x8,%esp
80105a2b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a31:	50                   	push   %eax
80105a32:	52                   	push   %edx
80105a33:	e8 ed f1 ff ff       	call   80104c25 <fetchint>
80105a38:	83 c4 10             	add    $0x10,%esp
80105a3b:	85 c0                	test   %eax,%eax
80105a3d:	79 07                	jns    80105a46 <sys_exec+0xa0>
      return -1;
80105a3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a44:	eb 66                	jmp    80105aac <sys_exec+0x106>
    if(uarg == 0){
80105a46:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a4c:	85 c0                	test   %eax,%eax
80105a4e:	75 27                	jne    80105a77 <sys_exec+0xd1>
      argv[i] = 0;
80105a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a53:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105a5a:	00 00 00 00 
      break;
80105a5e:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a62:	83 ec 08             	sub    $0x8,%esp
80105a65:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a6b:	52                   	push   %edx
80105a6c:	50                   	push   %eax
80105a6d:	e8 18 b1 ff ff       	call   80100b8a <exec>
80105a72:	83 c4 10             	add    $0x10,%esp
80105a75:	eb 35                	jmp    80105aac <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105a77:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105a7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a80:	c1 e2 02             	shl    $0x2,%edx
80105a83:	01 c2                	add    %eax,%edx
80105a85:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a8b:	83 ec 08             	sub    $0x8,%esp
80105a8e:	52                   	push   %edx
80105a8f:	50                   	push   %eax
80105a90:	e8 cf f1 ff ff       	call   80104c64 <fetchstr>
80105a95:	83 c4 10             	add    $0x10,%esp
80105a98:	85 c0                	test   %eax,%eax
80105a9a:	79 07                	jns    80105aa3 <sys_exec+0xfd>
      return -1;
80105a9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa1:	eb 09                	jmp    80105aac <sys_exec+0x106>
  for(i=0;; i++){
80105aa3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105aa7:	e9 5a ff ff ff       	jmp    80105a06 <sys_exec+0x60>
}
80105aac:	c9                   	leave
80105aad:	c3                   	ret

80105aae <sys_pipe>:

int
sys_pipe(void)
{
80105aae:	55                   	push   %ebp
80105aaf:	89 e5                	mov    %esp,%ebp
80105ab1:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105ab4:	83 ec 04             	sub    $0x4,%esp
80105ab7:	6a 08                	push   $0x8
80105ab9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105abc:	50                   	push   %eax
80105abd:	6a 00                	push   $0x0
80105abf:	e8 2f f2 ff ff       	call   80104cf3 <argptr>
80105ac4:	83 c4 10             	add    $0x10,%esp
80105ac7:	85 c0                	test   %eax,%eax
80105ac9:	79 0a                	jns    80105ad5 <sys_pipe+0x27>
    return -1;
80105acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad0:	e9 ae 00 00 00       	jmp    80105b83 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ad5:	83 ec 08             	sub    $0x8,%esp
80105ad8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105adb:	50                   	push   %eax
80105adc:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105adf:	50                   	push   %eax
80105ae0:	e8 88 da ff ff       	call   8010356d <pipealloc>
80105ae5:	83 c4 10             	add    $0x10,%esp
80105ae8:	85 c0                	test   %eax,%eax
80105aea:	79 0a                	jns    80105af6 <sys_pipe+0x48>
    return -1;
80105aec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af1:	e9 8d 00 00 00       	jmp    80105b83 <sys_pipe+0xd5>
  fd0 = -1;
80105af6:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105afd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b00:	83 ec 0c             	sub    $0xc,%esp
80105b03:	50                   	push   %eax
80105b04:	e8 7b f3 ff ff       	call   80104e84 <fdalloc>
80105b09:	83 c4 10             	add    $0x10,%esp
80105b0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b13:	78 18                	js     80105b2d <sys_pipe+0x7f>
80105b15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b18:	83 ec 0c             	sub    $0xc,%esp
80105b1b:	50                   	push   %eax
80105b1c:	e8 63 f3 ff ff       	call   80104e84 <fdalloc>
80105b21:	83 c4 10             	add    $0x10,%esp
80105b24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b2b:	79 3e                	jns    80105b6b <sys_pipe+0xbd>
    if(fd0 >= 0)
80105b2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b31:	78 13                	js     80105b46 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105b33:	e8 f8 de ff ff       	call   80103a30 <myproc>
80105b38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b3b:	83 c2 08             	add    $0x8,%edx
80105b3e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b45:	00 
    fileclose(rf);
80105b46:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b49:	83 ec 0c             	sub    $0xc,%esp
80105b4c:	50                   	push   %eax
80105b4d:	e8 53 b5 ff ff       	call   801010a5 <fileclose>
80105b52:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105b55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b58:	83 ec 0c             	sub    $0xc,%esp
80105b5b:	50                   	push   %eax
80105b5c:	e8 44 b5 ff ff       	call   801010a5 <fileclose>
80105b61:	83 c4 10             	add    $0x10,%esp
    return -1;
80105b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b69:	eb 18                	jmp    80105b83 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105b6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b71:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b76:	8d 50 04             	lea    0x4(%eax),%edx
80105b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b7c:	89 02                	mov    %eax,(%edx)
  return 0;
80105b7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b83:	c9                   	leave
80105b84:	c3                   	ret

80105b85 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105b85:	55                   	push   %ebp
80105b86:	89 e5                	mov    %esp,%ebp
80105b88:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105b8b:	e8 9f e1 ff ff       	call   80103d2f <fork>
}
80105b90:	c9                   	leave
80105b91:	c3                   	ret

80105b92 <sys_exit>:

int
sys_exit(void)
{
80105b92:	55                   	push   %ebp
80105b93:	89 e5                	mov    %esp,%ebp
80105b95:	83 ec 08             	sub    $0x8,%esp
  exit();
80105b98:	e8 0b e3 ff ff       	call   80103ea8 <exit>
  return 0;  // not reached
80105b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba2:	c9                   	leave
80105ba3:	c3                   	ret

80105ba4 <sys_wait>:

int
sys_wait(void)
{
80105ba4:	55                   	push   %ebp
80105ba5:	89 e5                	mov    %esp,%ebp
80105ba7:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105baa:	e8 19 e4 ff ff       	call   80103fc8 <wait>
}
80105baf:	c9                   	leave
80105bb0:	c3                   	ret

80105bb1 <sys_kill>:

int
sys_kill(void)
{
80105bb1:	55                   	push   %ebp
80105bb2:	89 e5                	mov    %esp,%ebp
80105bb4:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105bb7:	83 ec 08             	sub    $0x8,%esp
80105bba:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bbd:	50                   	push   %eax
80105bbe:	6a 00                	push   $0x0
80105bc0:	e8 01 f1 ff ff       	call   80104cc6 <argint>
80105bc5:	83 c4 10             	add    $0x10,%esp
80105bc8:	85 c0                	test   %eax,%eax
80105bca:	79 07                	jns    80105bd3 <sys_kill+0x22>
    return -1;
80105bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd1:	eb 0f                	jmp    80105be2 <sys_kill+0x31>
  return kill(pid);
80105bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd6:	83 ec 0c             	sub    $0xc,%esp
80105bd9:	50                   	push   %eax
80105bda:	e8 18 e8 ff ff       	call   801043f7 <kill>
80105bdf:	83 c4 10             	add    $0x10,%esp
}
80105be2:	c9                   	leave
80105be3:	c3                   	ret

80105be4 <sys_getpid>:

int
sys_getpid(void)
{
80105be4:	55                   	push   %ebp
80105be5:	89 e5                	mov    %esp,%ebp
80105be7:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105bea:	e8 41 de ff ff       	call   80103a30 <myproc>
80105bef:	8b 40 10             	mov    0x10(%eax),%eax
}
80105bf2:	c9                   	leave
80105bf3:	c3                   	ret

80105bf4 <sys_sbrk>:

int
sys_sbrk(void)
{
80105bf4:	55                   	push   %ebp
80105bf5:	89 e5                	mov    %esp,%ebp
80105bf7:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105bfa:	83 ec 08             	sub    $0x8,%esp
80105bfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c00:	50                   	push   %eax
80105c01:	6a 00                	push   $0x0
80105c03:	e8 be f0 ff ff       	call   80104cc6 <argint>
80105c08:	83 c4 10             	add    $0x10,%esp
80105c0b:	85 c0                	test   %eax,%eax
80105c0d:	79 07                	jns    80105c16 <sys_sbrk+0x22>
    return -1;
80105c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c14:	eb 27                	jmp    80105c3d <sys_sbrk+0x49>
  addr = myproc()->sz;
80105c16:	e8 15 de ff ff       	call   80103a30 <myproc>
80105c1b:	8b 00                	mov    (%eax),%eax
80105c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c23:	83 ec 0c             	sub    $0xc,%esp
80105c26:	50                   	push   %eax
80105c27:	e8 68 e0 ff ff       	call   80103c94 <growproc>
80105c2c:	83 c4 10             	add    $0x10,%esp
80105c2f:	85 c0                	test   %eax,%eax
80105c31:	79 07                	jns    80105c3a <sys_sbrk+0x46>
    return -1;
80105c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c38:	eb 03                	jmp    80105c3d <sys_sbrk+0x49>
  return addr;
80105c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c3d:	c9                   	leave
80105c3e:	c3                   	ret

80105c3f <sys_sleep>:

int
sys_sleep(void)
{
80105c3f:	55                   	push   %ebp
80105c40:	89 e5                	mov    %esp,%ebp
80105c42:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105c45:	83 ec 08             	sub    $0x8,%esp
80105c48:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c4b:	50                   	push   %eax
80105c4c:	6a 00                	push   $0x0
80105c4e:	e8 73 f0 ff ff       	call   80104cc6 <argint>
80105c53:	83 c4 10             	add    $0x10,%esp
80105c56:	85 c0                	test   %eax,%eax
80105c58:	79 07                	jns    80105c61 <sys_sleep+0x22>
    return -1;
80105c5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c5f:	eb 76                	jmp    80105cd7 <sys_sleep+0x98>
  acquire(&tickslock);
80105c61:	83 ec 0c             	sub    $0xc,%esp
80105c64:	68 40 6a 19 80       	push   $0x80196a40
80105c69:	e8 b7 ea ff ff       	call   80104725 <acquire>
80105c6e:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105c71:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105c76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105c79:	eb 38                	jmp    80105cb3 <sys_sleep+0x74>
    if(myproc()->killed){
80105c7b:	e8 b0 dd ff ff       	call   80103a30 <myproc>
80105c80:	8b 40 24             	mov    0x24(%eax),%eax
80105c83:	85 c0                	test   %eax,%eax
80105c85:	74 17                	je     80105c9e <sys_sleep+0x5f>
      release(&tickslock);
80105c87:	83 ec 0c             	sub    $0xc,%esp
80105c8a:	68 40 6a 19 80       	push   $0x80196a40
80105c8f:	e8 ff ea ff ff       	call   80104793 <release>
80105c94:	83 c4 10             	add    $0x10,%esp
      return -1;
80105c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9c:	eb 39                	jmp    80105cd7 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105c9e:	83 ec 08             	sub    $0x8,%esp
80105ca1:	68 40 6a 19 80       	push   $0x80196a40
80105ca6:	68 74 6a 19 80       	push   $0x80196a74
80105cab:	e8 29 e6 ff ff       	call   801042d9 <sleep>
80105cb0:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105cb3:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105cb8:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105cbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cbe:	39 d0                	cmp    %edx,%eax
80105cc0:	72 b9                	jb     80105c7b <sys_sleep+0x3c>
  }
  release(&tickslock);
80105cc2:	83 ec 0c             	sub    $0xc,%esp
80105cc5:	68 40 6a 19 80       	push   $0x80196a40
80105cca:	e8 c4 ea ff ff       	call   80104793 <release>
80105ccf:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cd7:	c9                   	leave
80105cd8:	c3                   	ret

80105cd9 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105cd9:	55                   	push   %ebp
80105cda:	89 e5                	mov    %esp,%ebp
80105cdc:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105cdf:	83 ec 0c             	sub    $0xc,%esp
80105ce2:	68 40 6a 19 80       	push   $0x80196a40
80105ce7:	e8 39 ea ff ff       	call   80104725 <acquire>
80105cec:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105cef:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105cf7:	83 ec 0c             	sub    $0xc,%esp
80105cfa:	68 40 6a 19 80       	push   $0x80196a40
80105cff:	e8 8f ea ff ff       	call   80104793 <release>
80105d04:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d0a:	c9                   	leave
80105d0b:	c3                   	ret

80105d0c <sys_uthread_init>:

int
sys_uthread_init(void)
{
80105d0c:	55                   	push   %ebp
80105d0d:	89 e5                	mov    %esp,%ebp
80105d0f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(0, &addr) < 0) {
80105d12:	83 ec 08             	sub    $0x8,%esp
80105d15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d18:	50                   	push   %eax
80105d19:	6a 00                	push   $0x0
80105d1b:	e8 a6 ef ff ff       	call   80104cc6 <argint>
80105d20:	83 c4 10             	add    $0x10,%esp
80105d23:	85 c0                	test   %eax,%eax
80105d25:	79 07                	jns    80105d2e <sys_uthread_init+0x22>
    return -1;
80105d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d2c:	eb 18                	jmp    80105d46 <sys_uthread_init+0x3a>
  }
  struct proc *p = myproc();
80105d2e:	e8 fd dc ff ff       	call   80103a30 <myproc>
80105d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->scheduler = (uint)addr;
80105d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d39:	89 c2                	mov    %eax,%edx
80105d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3e:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
80105d41:	b8 00 00 00 00       	mov    $0x0,%eax
80105d46:	c9                   	leave
80105d47:	c3                   	ret

80105d48 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105d48:	1e                   	push   %ds
  pushl %es
80105d49:	06                   	push   %es
  pushl %fs
80105d4a:	0f a0                	push   %fs
  pushl %gs
80105d4c:	0f a8                	push   %gs
  pushal
80105d4e:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105d4f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105d53:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105d55:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105d57:	54                   	push   %esp
  call trap
80105d58:	e8 d7 01 00 00       	call   80105f34 <trap>
  addl $4, %esp
80105d5d:	83 c4 04             	add    $0x4,%esp

80105d60 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105d60:	61                   	popa
  popl %gs
80105d61:	0f a9                	pop    %gs
  popl %fs
80105d63:	0f a1                	pop    %fs
  popl %es
80105d65:	07                   	pop    %es
  popl %ds
80105d66:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105d67:	83 c4 08             	add    $0x8,%esp
  iret
80105d6a:	cf                   	iret

80105d6b <lidt>:
{
80105d6b:	55                   	push   %ebp
80105d6c:	89 e5                	mov    %esp,%ebp
80105d6e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d74:	83 e8 01             	sub    $0x1,%eax
80105d77:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80105d7e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105d82:	8b 45 08             	mov    0x8(%ebp),%eax
80105d85:	c1 e8 10             	shr    $0x10,%eax
80105d88:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105d8c:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105d8f:	0f 01 18             	lidtl  (%eax)
}
80105d92:	90                   	nop
80105d93:	c9                   	leave
80105d94:	c3                   	ret

80105d95 <rcr2>:

static inline uint
rcr2(void)
{
80105d95:	55                   	push   %ebp
80105d96:	89 e5                	mov    %esp,%ebp
80105d98:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105d9b:	0f 20 d0             	mov    %cr2,%eax
80105d9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105da1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105da4:	c9                   	leave
80105da5:	c3                   	ret

80105da6 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105da6:	55                   	push   %ebp
80105da7:	89 e5                	mov    %esp,%ebp
80105da9:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105dac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105db3:	e9 c3 00 00 00       	jmp    80105e7b <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbb:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105dc2:	89 c2                	mov    %eax,%edx
80105dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc7:	66 89 14 c5 40 62 19 	mov    %dx,-0x7fe69dc0(,%eax,8)
80105dce:	80 
80105dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd2:	66 c7 04 c5 42 62 19 	movw   $0x8,-0x7fe69dbe(,%eax,8)
80105dd9:	80 08 00 
80105ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddf:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105de6:	80 
80105de7:	83 e2 e0             	and    $0xffffffe0,%edx
80105dea:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df4:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105dfb:	80 
80105dfc:	83 e2 1f             	and    $0x1f,%edx
80105dff:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e09:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e10:	80 
80105e11:	83 e2 f0             	and    $0xfffffff0,%edx
80105e14:	83 ca 0e             	or     $0xe,%edx
80105e17:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e21:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e28:	80 
80105e29:	83 e2 ef             	and    $0xffffffef,%edx
80105e2c:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e36:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e3d:	80 
80105e3e:	83 e2 9f             	and    $0xffffff9f,%edx
80105e41:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4b:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e52:	80 
80105e53:	83 ca 80             	or     $0xffffff80,%edx
80105e56:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e60:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105e67:	c1 e8 10             	shr    $0x10,%eax
80105e6a:	89 c2                	mov    %eax,%edx
80105e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6f:	66 89 14 c5 46 62 19 	mov    %dx,-0x7fe69dba(,%eax,8)
80105e76:	80 
  for(i = 0; i < 256; i++)
80105e77:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105e7b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105e82:	0f 8e 30 ff ff ff    	jle    80105db8 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105e88:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105e8d:	66 a3 40 64 19 80    	mov    %ax,0x80196440
80105e93:	66 c7 05 42 64 19 80 	movw   $0x8,0x80196442
80105e9a:	08 00 
80105e9c:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105ea3:	83 e0 e0             	and    $0xffffffe0,%eax
80105ea6:	a2 44 64 19 80       	mov    %al,0x80196444
80105eab:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105eb2:	83 e0 1f             	and    $0x1f,%eax
80105eb5:	a2 44 64 19 80       	mov    %al,0x80196444
80105eba:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105ec1:	83 c8 0f             	or     $0xf,%eax
80105ec4:	a2 45 64 19 80       	mov    %al,0x80196445
80105ec9:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105ed0:	83 e0 ef             	and    $0xffffffef,%eax
80105ed3:	a2 45 64 19 80       	mov    %al,0x80196445
80105ed8:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105edf:	83 c8 60             	or     $0x60,%eax
80105ee2:	a2 45 64 19 80       	mov    %al,0x80196445
80105ee7:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105eee:	83 c8 80             	or     $0xffffff80,%eax
80105ef1:	a2 45 64 19 80       	mov    %al,0x80196445
80105ef6:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105efb:	c1 e8 10             	shr    $0x10,%eax
80105efe:	66 a3 46 64 19 80    	mov    %ax,0x80196446

  initlock(&tickslock, "time");
80105f04:	83 ec 08             	sub    $0x8,%esp
80105f07:	68 a4 a4 10 80       	push   $0x8010a4a4
80105f0c:	68 40 6a 19 80       	push   $0x80196a40
80105f11:	e8 ed e7 ff ff       	call   80104703 <initlock>
80105f16:	83 c4 10             	add    $0x10,%esp
}
80105f19:	90                   	nop
80105f1a:	c9                   	leave
80105f1b:	c3                   	ret

80105f1c <idtinit>:

void
idtinit(void)
{
80105f1c:	55                   	push   %ebp
80105f1d:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105f1f:	68 00 08 00 00       	push   $0x800
80105f24:	68 40 62 19 80       	push   $0x80196240
80105f29:	e8 3d fe ff ff       	call   80105d6b <lidt>
80105f2e:	83 c4 08             	add    $0x8,%esp
}
80105f31:	90                   	nop
80105f32:	c9                   	leave
80105f33:	c3                   	ret

80105f34 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f34:	55                   	push   %ebp
80105f35:	89 e5                	mov    %esp,%ebp
80105f37:	57                   	push   %edi
80105f38:	56                   	push   %esi
80105f39:	53                   	push   %ebx
80105f3a:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80105f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f40:	8b 40 30             	mov    0x30(%eax),%eax
80105f43:	83 f8 40             	cmp    $0x40,%eax
80105f46:	75 3b                	jne    80105f83 <trap+0x4f>
    if(myproc()->killed)
80105f48:	e8 e3 da ff ff       	call   80103a30 <myproc>
80105f4d:	8b 40 24             	mov    0x24(%eax),%eax
80105f50:	85 c0                	test   %eax,%eax
80105f52:	74 05                	je     80105f59 <trap+0x25>
      exit();
80105f54:	e8 4f df ff ff       	call   80103ea8 <exit>
    myproc()->tf = tf;
80105f59:	e8 d2 da ff ff       	call   80103a30 <myproc>
80105f5e:	8b 55 08             	mov    0x8(%ebp),%edx
80105f61:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80105f64:	e8 29 ee ff ff       	call   80104d92 <syscall>
    if(myproc()->killed)
80105f69:	e8 c2 da ff ff       	call   80103a30 <myproc>
80105f6e:	8b 40 24             	mov    0x24(%eax),%eax
80105f71:	85 c0                	test   %eax,%eax
80105f73:	0f 84 8f 02 00 00    	je     80106208 <trap+0x2d4>
      exit();
80105f79:	e8 2a df ff ff       	call   80103ea8 <exit>
    return;
80105f7e:	e9 85 02 00 00       	jmp    80106208 <trap+0x2d4>
  }

  switch(tf->trapno){
80105f83:	8b 45 08             	mov    0x8(%ebp),%eax
80105f86:	8b 40 30             	mov    0x30(%eax),%eax
80105f89:	83 e8 20             	sub    $0x20,%eax
80105f8c:	83 f8 1f             	cmp    $0x1f,%eax
80105f8f:	0f 87 3b 01 00 00    	ja     801060d0 <trap+0x19c>
80105f95:	8b 04 85 4c a5 10 80 	mov    -0x7fef5ab4(,%eax,4),%eax
80105f9c:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105f9e:	e8 fa d9 ff ff       	call   8010399d <cpuid>
80105fa3:	85 c0                	test   %eax,%eax
80105fa5:	75 3d                	jne    80105fe4 <trap+0xb0>
      acquire(&tickslock);
80105fa7:	83 ec 0c             	sub    $0xc,%esp
80105faa:	68 40 6a 19 80       	push   $0x80196a40
80105faf:	e8 71 e7 ff ff       	call   80104725 <acquire>
80105fb4:	83 c4 10             	add    $0x10,%esp
      ticks++;
80105fb7:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105fbc:	83 c0 01             	add    $0x1,%eax
80105fbf:	a3 74 6a 19 80       	mov    %eax,0x80196a74
      wakeup(&ticks);
80105fc4:	83 ec 0c             	sub    $0xc,%esp
80105fc7:	68 74 6a 19 80       	push   $0x80196a74
80105fcc:	e8 ef e3 ff ff       	call   801043c0 <wakeup>
80105fd1:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80105fd4:	83 ec 0c             	sub    $0xc,%esp
80105fd7:	68 40 6a 19 80       	push   $0x80196a40
80105fdc:	e8 b2 e7 ff ff       	call   80104793 <release>
80105fe1:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80105fe4:	e8 35 cb ff ff       	call   80102b1e <lapiceoi>
    // New code for scheduler
    if(myproc() && (tf->cs&3) == DPL_USER) {
80105fe9:	e8 42 da ff ff       	call   80103a30 <myproc>
80105fee:	85 c0                	test   %eax,%eax
80105ff0:	0f 84 91 01 00 00    	je     80106187 <trap+0x253>
80105ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80105ffd:	0f b7 c0             	movzwl %ax,%eax
80106000:	83 e0 03             	and    $0x3,%eax
80106003:	83 f8 03             	cmp    $0x3,%eax
80106006:	0f 85 7b 01 00 00    	jne    80106187 <trap+0x253>
      if(myproc()->state == RUNNING && myproc()->scheduler)
8010600c:	e8 1f da ff ff       	call   80103a30 <myproc>
80106011:	8b 40 0c             	mov    0xc(%eax),%eax
80106014:	83 f8 04             	cmp    $0x4,%eax
80106017:	0f 85 6a 01 00 00    	jne    80106187 <trap+0x253>
8010601d:	e8 0e da ff ff       	call   80103a30 <myproc>
80106022:	8b 40 7c             	mov    0x7c(%eax),%eax
80106025:	85 c0                	test   %eax,%eax
80106027:	0f 84 5a 01 00 00    	je     80106187 <trap+0x253>
      {
        uint ret_addr = tf->eip;
8010602d:	8b 45 08             	mov    0x8(%ebp),%eax
80106030:	8b 40 38             	mov    0x38(%eax),%eax
80106033:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        tf->esp -= 4;
80106036:	8b 45 08             	mov    0x8(%ebp),%eax
80106039:	8b 40 44             	mov    0x44(%eax),%eax
8010603c:	8d 50 fc             	lea    -0x4(%eax),%edx
8010603f:	8b 45 08             	mov    0x8(%ebp),%eax
80106042:	89 50 44             	mov    %edx,0x44(%eax)
        *(uint*)tf->esp = ret_addr;
80106045:	8b 45 08             	mov    0x8(%ebp),%eax
80106048:	8b 40 44             	mov    0x44(%eax),%eax
8010604b:	89 c2                	mov    %eax,%edx
8010604d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106050:	89 02                	mov    %eax,(%edx)
        tf->eip = myproc()->scheduler;
80106052:	e8 d9 d9 ff ff       	call   80103a30 <myproc>
80106057:	8b 50 7c             	mov    0x7c(%eax),%edx
8010605a:	8b 45 08             	mov    0x8(%ebp),%eax
8010605d:	89 50 38             	mov    %edx,0x38(%eax)
      } 
    }
    break;
80106060:	e9 22 01 00 00       	jmp    80106187 <trap+0x253>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106065:	e8 de 3e 00 00       	call   80109f48 <ideintr>
    lapiceoi();
8010606a:	e8 af ca ff ff       	call   80102b1e <lapiceoi>
    break;
8010606f:	e9 14 01 00 00       	jmp    80106188 <trap+0x254>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106074:	e8 f0 c8 ff ff       	call   80102969 <kbdintr>
    lapiceoi();
80106079:	e8 a0 ca ff ff       	call   80102b1e <lapiceoi>
    break;
8010607e:	e9 05 01 00 00       	jmp    80106188 <trap+0x254>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106083:	e8 54 03 00 00       	call   801063dc <uartintr>
    lapiceoi();
80106088:	e8 91 ca ff ff       	call   80102b1e <lapiceoi>
    break;
8010608d:	e9 f6 00 00 00       	jmp    80106188 <trap+0x254>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106092:	e8 7a 2b 00 00       	call   80108c11 <i8254_intr>
    lapiceoi();
80106097:	e8 82 ca ff ff       	call   80102b1e <lapiceoi>
    break;
8010609c:	e9 e7 00 00 00       	jmp    80106188 <trap+0x254>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060a1:	8b 45 08             	mov    0x8(%ebp),%eax
801060a4:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801060a7:	8b 45 08             	mov    0x8(%ebp),%eax
801060aa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060ae:	0f b7 d8             	movzwl %ax,%ebx
801060b1:	e8 e7 d8 ff ff       	call   8010399d <cpuid>
801060b6:	56                   	push   %esi
801060b7:	53                   	push   %ebx
801060b8:	50                   	push   %eax
801060b9:	68 ac a4 10 80       	push   $0x8010a4ac
801060be:	e8 31 a3 ff ff       	call   801003f4 <cprintf>
801060c3:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801060c6:	e8 53 ca ff ff       	call   80102b1e <lapiceoi>
    break;
801060cb:	e9 b8 00 00 00       	jmp    80106188 <trap+0x254>
  
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801060d0:	e8 5b d9 ff ff       	call   80103a30 <myproc>
801060d5:	85 c0                	test   %eax,%eax
801060d7:	74 11                	je     801060ea <trap+0x1b6>
801060d9:	8b 45 08             	mov    0x8(%ebp),%eax
801060dc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801060e0:	0f b7 c0             	movzwl %ax,%eax
801060e3:	83 e0 03             	and    $0x3,%eax
801060e6:	85 c0                	test   %eax,%eax
801060e8:	75 39                	jne    80106123 <trap+0x1ef>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801060ea:	e8 a6 fc ff ff       	call   80105d95 <rcr2>
801060ef:	89 c3                	mov    %eax,%ebx
801060f1:	8b 45 08             	mov    0x8(%ebp),%eax
801060f4:	8b 70 38             	mov    0x38(%eax),%esi
801060f7:	e8 a1 d8 ff ff       	call   8010399d <cpuid>
801060fc:	8b 55 08             	mov    0x8(%ebp),%edx
801060ff:	8b 52 30             	mov    0x30(%edx),%edx
80106102:	83 ec 0c             	sub    $0xc,%esp
80106105:	53                   	push   %ebx
80106106:	56                   	push   %esi
80106107:	50                   	push   %eax
80106108:	52                   	push   %edx
80106109:	68 d0 a4 10 80       	push   $0x8010a4d0
8010610e:	e8 e1 a2 ff ff       	call   801003f4 <cprintf>
80106113:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106116:	83 ec 0c             	sub    $0xc,%esp
80106119:	68 02 a5 10 80       	push   $0x8010a502
8010611e:	e8 86 a4 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106123:	e8 6d fc ff ff       	call   80105d95 <rcr2>
80106128:	89 c6                	mov    %eax,%esi
8010612a:	8b 45 08             	mov    0x8(%ebp),%eax
8010612d:	8b 40 38             	mov    0x38(%eax),%eax
80106130:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106133:	e8 65 d8 ff ff       	call   8010399d <cpuid>
80106138:	89 c3                	mov    %eax,%ebx
8010613a:	8b 45 08             	mov    0x8(%ebp),%eax
8010613d:	8b 48 34             	mov    0x34(%eax),%ecx
80106140:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106143:	8b 45 08             	mov    0x8(%ebp),%eax
80106146:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106149:	e8 e2 d8 ff ff       	call   80103a30 <myproc>
8010614e:	8d 50 6c             	lea    0x6c(%eax),%edx
80106151:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106154:	e8 d7 d8 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106159:	8b 40 10             	mov    0x10(%eax),%eax
8010615c:	56                   	push   %esi
8010615d:	ff 75 d4             	push   -0x2c(%ebp)
80106160:	53                   	push   %ebx
80106161:	ff 75 d0             	push   -0x30(%ebp)
80106164:	57                   	push   %edi
80106165:	ff 75 cc             	push   -0x34(%ebp)
80106168:	50                   	push   %eax
80106169:	68 08 a5 10 80       	push   $0x8010a508
8010616e:	e8 81 a2 ff ff       	call   801003f4 <cprintf>
80106173:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106176:	e8 b5 d8 ff ff       	call   80103a30 <myproc>
8010617b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106182:	eb 04                	jmp    80106188 <trap+0x254>
    break;
80106184:	90                   	nop
80106185:	eb 01                	jmp    80106188 <trap+0x254>
    break;
80106187:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106188:	e8 a3 d8 ff ff       	call   80103a30 <myproc>
8010618d:	85 c0                	test   %eax,%eax
8010618f:	74 23                	je     801061b4 <trap+0x280>
80106191:	e8 9a d8 ff ff       	call   80103a30 <myproc>
80106196:	8b 40 24             	mov    0x24(%eax),%eax
80106199:	85 c0                	test   %eax,%eax
8010619b:	74 17                	je     801061b4 <trap+0x280>
8010619d:	8b 45 08             	mov    0x8(%ebp),%eax
801061a0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061a4:	0f b7 c0             	movzwl %ax,%eax
801061a7:	83 e0 03             	and    $0x3,%eax
801061aa:	83 f8 03             	cmp    $0x3,%eax
801061ad:	75 05                	jne    801061b4 <trap+0x280>
    exit();
801061af:	e8 f4 dc ff ff       	call   80103ea8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801061b4:	e8 77 d8 ff ff       	call   80103a30 <myproc>
801061b9:	85 c0                	test   %eax,%eax
801061bb:	74 1d                	je     801061da <trap+0x2a6>
801061bd:	e8 6e d8 ff ff       	call   80103a30 <myproc>
801061c2:	8b 40 0c             	mov    0xc(%eax),%eax
801061c5:	83 f8 04             	cmp    $0x4,%eax
801061c8:	75 10                	jne    801061da <trap+0x2a6>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801061ca:	8b 45 08             	mov    0x8(%ebp),%eax
801061cd:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801061d0:	83 f8 20             	cmp    $0x20,%eax
801061d3:	75 05                	jne    801061da <trap+0x2a6>
    yield();
801061d5:	e8 7f e0 ff ff       	call   80104259 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801061da:	e8 51 d8 ff ff       	call   80103a30 <myproc>
801061df:	85 c0                	test   %eax,%eax
801061e1:	74 26                	je     80106209 <trap+0x2d5>
801061e3:	e8 48 d8 ff ff       	call   80103a30 <myproc>
801061e8:	8b 40 24             	mov    0x24(%eax),%eax
801061eb:	85 c0                	test   %eax,%eax
801061ed:	74 1a                	je     80106209 <trap+0x2d5>
801061ef:	8b 45 08             	mov    0x8(%ebp),%eax
801061f2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061f6:	0f b7 c0             	movzwl %ax,%eax
801061f9:	83 e0 03             	and    $0x3,%eax
801061fc:	83 f8 03             	cmp    $0x3,%eax
801061ff:	75 08                	jne    80106209 <trap+0x2d5>
    exit();
80106201:	e8 a2 dc ff ff       	call   80103ea8 <exit>
80106206:	eb 01                	jmp    80106209 <trap+0x2d5>
    return;
80106208:	90                   	nop
}
80106209:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010620c:	5b                   	pop    %ebx
8010620d:	5e                   	pop    %esi
8010620e:	5f                   	pop    %edi
8010620f:	5d                   	pop    %ebp
80106210:	c3                   	ret

80106211 <inb>:
{
80106211:	55                   	push   %ebp
80106212:	89 e5                	mov    %esp,%ebp
80106214:	83 ec 14             	sub    $0x14,%esp
80106217:	8b 45 08             	mov    0x8(%ebp),%eax
8010621a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010621e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106222:	89 c2                	mov    %eax,%edx
80106224:	ec                   	in     (%dx),%al
80106225:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106228:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010622c:	c9                   	leave
8010622d:	c3                   	ret

8010622e <outb>:
{
8010622e:	55                   	push   %ebp
8010622f:	89 e5                	mov    %esp,%ebp
80106231:	83 ec 08             	sub    $0x8,%esp
80106234:	8b 55 08             	mov    0x8(%ebp),%edx
80106237:	8b 45 0c             	mov    0xc(%ebp),%eax
8010623a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010623e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106241:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106245:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106249:	ee                   	out    %al,(%dx)
}
8010624a:	90                   	nop
8010624b:	c9                   	leave
8010624c:	c3                   	ret

8010624d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010624d:	55                   	push   %ebp
8010624e:	89 e5                	mov    %esp,%ebp
80106250:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106253:	6a 00                	push   $0x0
80106255:	68 fa 03 00 00       	push   $0x3fa
8010625a:	e8 cf ff ff ff       	call   8010622e <outb>
8010625f:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106262:	68 80 00 00 00       	push   $0x80
80106267:	68 fb 03 00 00       	push   $0x3fb
8010626c:	e8 bd ff ff ff       	call   8010622e <outb>
80106271:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106274:	6a 0c                	push   $0xc
80106276:	68 f8 03 00 00       	push   $0x3f8
8010627b:	e8 ae ff ff ff       	call   8010622e <outb>
80106280:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106283:	6a 00                	push   $0x0
80106285:	68 f9 03 00 00       	push   $0x3f9
8010628a:	e8 9f ff ff ff       	call   8010622e <outb>
8010628f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106292:	6a 03                	push   $0x3
80106294:	68 fb 03 00 00       	push   $0x3fb
80106299:	e8 90 ff ff ff       	call   8010622e <outb>
8010629e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801062a1:	6a 00                	push   $0x0
801062a3:	68 fc 03 00 00       	push   $0x3fc
801062a8:	e8 81 ff ff ff       	call   8010622e <outb>
801062ad:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801062b0:	6a 01                	push   $0x1
801062b2:	68 f9 03 00 00       	push   $0x3f9
801062b7:	e8 72 ff ff ff       	call   8010622e <outb>
801062bc:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801062bf:	68 fd 03 00 00       	push   $0x3fd
801062c4:	e8 48 ff ff ff       	call   80106211 <inb>
801062c9:	83 c4 04             	add    $0x4,%esp
801062cc:	3c ff                	cmp    $0xff,%al
801062ce:	74 61                	je     80106331 <uartinit+0xe4>
    return;
  uart = 1;
801062d0:	c7 05 78 6a 19 80 01 	movl   $0x1,0x80196a78
801062d7:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801062da:	68 fa 03 00 00       	push   $0x3fa
801062df:	e8 2d ff ff ff       	call   80106211 <inb>
801062e4:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801062e7:	68 f8 03 00 00       	push   $0x3f8
801062ec:	e8 20 ff ff ff       	call   80106211 <inb>
801062f1:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801062f4:	83 ec 08             	sub    $0x8,%esp
801062f7:	6a 00                	push   $0x0
801062f9:	6a 04                	push   $0x4
801062fb:	e8 36 c3 ff ff       	call   80102636 <ioapicenable>
80106300:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106303:	c7 45 f4 cc a5 10 80 	movl   $0x8010a5cc,-0xc(%ebp)
8010630a:	eb 19                	jmp    80106325 <uartinit+0xd8>
    uartputc(*p);
8010630c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010630f:	0f b6 00             	movzbl (%eax),%eax
80106312:	0f be c0             	movsbl %al,%eax
80106315:	83 ec 0c             	sub    $0xc,%esp
80106318:	50                   	push   %eax
80106319:	e8 16 00 00 00       	call   80106334 <uartputc>
8010631e:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106321:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106328:	0f b6 00             	movzbl (%eax),%eax
8010632b:	84 c0                	test   %al,%al
8010632d:	75 dd                	jne    8010630c <uartinit+0xbf>
8010632f:	eb 01                	jmp    80106332 <uartinit+0xe5>
    return;
80106331:	90                   	nop
}
80106332:	c9                   	leave
80106333:	c3                   	ret

80106334 <uartputc>:

void
uartputc(int c)
{
80106334:	55                   	push   %ebp
80106335:	89 e5                	mov    %esp,%ebp
80106337:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010633a:	a1 78 6a 19 80       	mov    0x80196a78,%eax
8010633f:	85 c0                	test   %eax,%eax
80106341:	74 53                	je     80106396 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106343:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010634a:	eb 11                	jmp    8010635d <uartputc+0x29>
    microdelay(10);
8010634c:	83 ec 0c             	sub    $0xc,%esp
8010634f:	6a 0a                	push   $0xa
80106351:	e8 e3 c7 ff ff       	call   80102b39 <microdelay>
80106356:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106359:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010635d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106361:	7f 1a                	jg     8010637d <uartputc+0x49>
80106363:	83 ec 0c             	sub    $0xc,%esp
80106366:	68 fd 03 00 00       	push   $0x3fd
8010636b:	e8 a1 fe ff ff       	call   80106211 <inb>
80106370:	83 c4 10             	add    $0x10,%esp
80106373:	0f b6 c0             	movzbl %al,%eax
80106376:	83 e0 20             	and    $0x20,%eax
80106379:	85 c0                	test   %eax,%eax
8010637b:	74 cf                	je     8010634c <uartputc+0x18>
  outb(COM1+0, c);
8010637d:	8b 45 08             	mov    0x8(%ebp),%eax
80106380:	0f b6 c0             	movzbl %al,%eax
80106383:	83 ec 08             	sub    $0x8,%esp
80106386:	50                   	push   %eax
80106387:	68 f8 03 00 00       	push   $0x3f8
8010638c:	e8 9d fe ff ff       	call   8010622e <outb>
80106391:	83 c4 10             	add    $0x10,%esp
80106394:	eb 01                	jmp    80106397 <uartputc+0x63>
    return;
80106396:	90                   	nop
}
80106397:	c9                   	leave
80106398:	c3                   	ret

80106399 <uartgetc>:

static int
uartgetc(void)
{
80106399:	55                   	push   %ebp
8010639a:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010639c:	a1 78 6a 19 80       	mov    0x80196a78,%eax
801063a1:	85 c0                	test   %eax,%eax
801063a3:	75 07                	jne    801063ac <uartgetc+0x13>
    return -1;
801063a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063aa:	eb 2e                	jmp    801063da <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
801063ac:	68 fd 03 00 00       	push   $0x3fd
801063b1:	e8 5b fe ff ff       	call   80106211 <inb>
801063b6:	83 c4 04             	add    $0x4,%esp
801063b9:	0f b6 c0             	movzbl %al,%eax
801063bc:	83 e0 01             	and    $0x1,%eax
801063bf:	85 c0                	test   %eax,%eax
801063c1:	75 07                	jne    801063ca <uartgetc+0x31>
    return -1;
801063c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c8:	eb 10                	jmp    801063da <uartgetc+0x41>
  return inb(COM1+0);
801063ca:	68 f8 03 00 00       	push   $0x3f8
801063cf:	e8 3d fe ff ff       	call   80106211 <inb>
801063d4:	83 c4 04             	add    $0x4,%esp
801063d7:	0f b6 c0             	movzbl %al,%eax
}
801063da:	c9                   	leave
801063db:	c3                   	ret

801063dc <uartintr>:

void
uartintr(void)
{
801063dc:	55                   	push   %ebp
801063dd:	89 e5                	mov    %esp,%ebp
801063df:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801063e2:	83 ec 0c             	sub    $0xc,%esp
801063e5:	68 99 63 10 80       	push   $0x80106399
801063ea:	e8 e7 a3 ff ff       	call   801007d6 <consoleintr>
801063ef:	83 c4 10             	add    $0x10,%esp
}
801063f2:	90                   	nop
801063f3:	c9                   	leave
801063f4:	c3                   	ret

801063f5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801063f5:	6a 00                	push   $0x0
  pushl $0
801063f7:	6a 00                	push   $0x0
  jmp alltraps
801063f9:	e9 4a f9 ff ff       	jmp    80105d48 <alltraps>

801063fe <vector1>:
.globl vector1
vector1:
  pushl $0
801063fe:	6a 00                	push   $0x0
  pushl $1
80106400:	6a 01                	push   $0x1
  jmp alltraps
80106402:	e9 41 f9 ff ff       	jmp    80105d48 <alltraps>

80106407 <vector2>:
.globl vector2
vector2:
  pushl $0
80106407:	6a 00                	push   $0x0
  pushl $2
80106409:	6a 02                	push   $0x2
  jmp alltraps
8010640b:	e9 38 f9 ff ff       	jmp    80105d48 <alltraps>

80106410 <vector3>:
.globl vector3
vector3:
  pushl $0
80106410:	6a 00                	push   $0x0
  pushl $3
80106412:	6a 03                	push   $0x3
  jmp alltraps
80106414:	e9 2f f9 ff ff       	jmp    80105d48 <alltraps>

80106419 <vector4>:
.globl vector4
vector4:
  pushl $0
80106419:	6a 00                	push   $0x0
  pushl $4
8010641b:	6a 04                	push   $0x4
  jmp alltraps
8010641d:	e9 26 f9 ff ff       	jmp    80105d48 <alltraps>

80106422 <vector5>:
.globl vector5
vector5:
  pushl $0
80106422:	6a 00                	push   $0x0
  pushl $5
80106424:	6a 05                	push   $0x5
  jmp alltraps
80106426:	e9 1d f9 ff ff       	jmp    80105d48 <alltraps>

8010642b <vector6>:
.globl vector6
vector6:
  pushl $0
8010642b:	6a 00                	push   $0x0
  pushl $6
8010642d:	6a 06                	push   $0x6
  jmp alltraps
8010642f:	e9 14 f9 ff ff       	jmp    80105d48 <alltraps>

80106434 <vector7>:
.globl vector7
vector7:
  pushl $0
80106434:	6a 00                	push   $0x0
  pushl $7
80106436:	6a 07                	push   $0x7
  jmp alltraps
80106438:	e9 0b f9 ff ff       	jmp    80105d48 <alltraps>

8010643d <vector8>:
.globl vector8
vector8:
  pushl $8
8010643d:	6a 08                	push   $0x8
  jmp alltraps
8010643f:	e9 04 f9 ff ff       	jmp    80105d48 <alltraps>

80106444 <vector9>:
.globl vector9
vector9:
  pushl $0
80106444:	6a 00                	push   $0x0
  pushl $9
80106446:	6a 09                	push   $0x9
  jmp alltraps
80106448:	e9 fb f8 ff ff       	jmp    80105d48 <alltraps>

8010644d <vector10>:
.globl vector10
vector10:
  pushl $10
8010644d:	6a 0a                	push   $0xa
  jmp alltraps
8010644f:	e9 f4 f8 ff ff       	jmp    80105d48 <alltraps>

80106454 <vector11>:
.globl vector11
vector11:
  pushl $11
80106454:	6a 0b                	push   $0xb
  jmp alltraps
80106456:	e9 ed f8 ff ff       	jmp    80105d48 <alltraps>

8010645b <vector12>:
.globl vector12
vector12:
  pushl $12
8010645b:	6a 0c                	push   $0xc
  jmp alltraps
8010645d:	e9 e6 f8 ff ff       	jmp    80105d48 <alltraps>

80106462 <vector13>:
.globl vector13
vector13:
  pushl $13
80106462:	6a 0d                	push   $0xd
  jmp alltraps
80106464:	e9 df f8 ff ff       	jmp    80105d48 <alltraps>

80106469 <vector14>:
.globl vector14
vector14:
  pushl $14
80106469:	6a 0e                	push   $0xe
  jmp alltraps
8010646b:	e9 d8 f8 ff ff       	jmp    80105d48 <alltraps>

80106470 <vector15>:
.globl vector15
vector15:
  pushl $0
80106470:	6a 00                	push   $0x0
  pushl $15
80106472:	6a 0f                	push   $0xf
  jmp alltraps
80106474:	e9 cf f8 ff ff       	jmp    80105d48 <alltraps>

80106479 <vector16>:
.globl vector16
vector16:
  pushl $0
80106479:	6a 00                	push   $0x0
  pushl $16
8010647b:	6a 10                	push   $0x10
  jmp alltraps
8010647d:	e9 c6 f8 ff ff       	jmp    80105d48 <alltraps>

80106482 <vector17>:
.globl vector17
vector17:
  pushl $17
80106482:	6a 11                	push   $0x11
  jmp alltraps
80106484:	e9 bf f8 ff ff       	jmp    80105d48 <alltraps>

80106489 <vector18>:
.globl vector18
vector18:
  pushl $0
80106489:	6a 00                	push   $0x0
  pushl $18
8010648b:	6a 12                	push   $0x12
  jmp alltraps
8010648d:	e9 b6 f8 ff ff       	jmp    80105d48 <alltraps>

80106492 <vector19>:
.globl vector19
vector19:
  pushl $0
80106492:	6a 00                	push   $0x0
  pushl $19
80106494:	6a 13                	push   $0x13
  jmp alltraps
80106496:	e9 ad f8 ff ff       	jmp    80105d48 <alltraps>

8010649b <vector20>:
.globl vector20
vector20:
  pushl $0
8010649b:	6a 00                	push   $0x0
  pushl $20
8010649d:	6a 14                	push   $0x14
  jmp alltraps
8010649f:	e9 a4 f8 ff ff       	jmp    80105d48 <alltraps>

801064a4 <vector21>:
.globl vector21
vector21:
  pushl $0
801064a4:	6a 00                	push   $0x0
  pushl $21
801064a6:	6a 15                	push   $0x15
  jmp alltraps
801064a8:	e9 9b f8 ff ff       	jmp    80105d48 <alltraps>

801064ad <vector22>:
.globl vector22
vector22:
  pushl $0
801064ad:	6a 00                	push   $0x0
  pushl $22
801064af:	6a 16                	push   $0x16
  jmp alltraps
801064b1:	e9 92 f8 ff ff       	jmp    80105d48 <alltraps>

801064b6 <vector23>:
.globl vector23
vector23:
  pushl $0
801064b6:	6a 00                	push   $0x0
  pushl $23
801064b8:	6a 17                	push   $0x17
  jmp alltraps
801064ba:	e9 89 f8 ff ff       	jmp    80105d48 <alltraps>

801064bf <vector24>:
.globl vector24
vector24:
  pushl $0
801064bf:	6a 00                	push   $0x0
  pushl $24
801064c1:	6a 18                	push   $0x18
  jmp alltraps
801064c3:	e9 80 f8 ff ff       	jmp    80105d48 <alltraps>

801064c8 <vector25>:
.globl vector25
vector25:
  pushl $0
801064c8:	6a 00                	push   $0x0
  pushl $25
801064ca:	6a 19                	push   $0x19
  jmp alltraps
801064cc:	e9 77 f8 ff ff       	jmp    80105d48 <alltraps>

801064d1 <vector26>:
.globl vector26
vector26:
  pushl $0
801064d1:	6a 00                	push   $0x0
  pushl $26
801064d3:	6a 1a                	push   $0x1a
  jmp alltraps
801064d5:	e9 6e f8 ff ff       	jmp    80105d48 <alltraps>

801064da <vector27>:
.globl vector27
vector27:
  pushl $0
801064da:	6a 00                	push   $0x0
  pushl $27
801064dc:	6a 1b                	push   $0x1b
  jmp alltraps
801064de:	e9 65 f8 ff ff       	jmp    80105d48 <alltraps>

801064e3 <vector28>:
.globl vector28
vector28:
  pushl $0
801064e3:	6a 00                	push   $0x0
  pushl $28
801064e5:	6a 1c                	push   $0x1c
  jmp alltraps
801064e7:	e9 5c f8 ff ff       	jmp    80105d48 <alltraps>

801064ec <vector29>:
.globl vector29
vector29:
  pushl $0
801064ec:	6a 00                	push   $0x0
  pushl $29
801064ee:	6a 1d                	push   $0x1d
  jmp alltraps
801064f0:	e9 53 f8 ff ff       	jmp    80105d48 <alltraps>

801064f5 <vector30>:
.globl vector30
vector30:
  pushl $0
801064f5:	6a 00                	push   $0x0
  pushl $30
801064f7:	6a 1e                	push   $0x1e
  jmp alltraps
801064f9:	e9 4a f8 ff ff       	jmp    80105d48 <alltraps>

801064fe <vector31>:
.globl vector31
vector31:
  pushl $0
801064fe:	6a 00                	push   $0x0
  pushl $31
80106500:	6a 1f                	push   $0x1f
  jmp alltraps
80106502:	e9 41 f8 ff ff       	jmp    80105d48 <alltraps>

80106507 <vector32>:
.globl vector32
vector32:
  pushl $0
80106507:	6a 00                	push   $0x0
  pushl $32
80106509:	6a 20                	push   $0x20
  jmp alltraps
8010650b:	e9 38 f8 ff ff       	jmp    80105d48 <alltraps>

80106510 <vector33>:
.globl vector33
vector33:
  pushl $0
80106510:	6a 00                	push   $0x0
  pushl $33
80106512:	6a 21                	push   $0x21
  jmp alltraps
80106514:	e9 2f f8 ff ff       	jmp    80105d48 <alltraps>

80106519 <vector34>:
.globl vector34
vector34:
  pushl $0
80106519:	6a 00                	push   $0x0
  pushl $34
8010651b:	6a 22                	push   $0x22
  jmp alltraps
8010651d:	e9 26 f8 ff ff       	jmp    80105d48 <alltraps>

80106522 <vector35>:
.globl vector35
vector35:
  pushl $0
80106522:	6a 00                	push   $0x0
  pushl $35
80106524:	6a 23                	push   $0x23
  jmp alltraps
80106526:	e9 1d f8 ff ff       	jmp    80105d48 <alltraps>

8010652b <vector36>:
.globl vector36
vector36:
  pushl $0
8010652b:	6a 00                	push   $0x0
  pushl $36
8010652d:	6a 24                	push   $0x24
  jmp alltraps
8010652f:	e9 14 f8 ff ff       	jmp    80105d48 <alltraps>

80106534 <vector37>:
.globl vector37
vector37:
  pushl $0
80106534:	6a 00                	push   $0x0
  pushl $37
80106536:	6a 25                	push   $0x25
  jmp alltraps
80106538:	e9 0b f8 ff ff       	jmp    80105d48 <alltraps>

8010653d <vector38>:
.globl vector38
vector38:
  pushl $0
8010653d:	6a 00                	push   $0x0
  pushl $38
8010653f:	6a 26                	push   $0x26
  jmp alltraps
80106541:	e9 02 f8 ff ff       	jmp    80105d48 <alltraps>

80106546 <vector39>:
.globl vector39
vector39:
  pushl $0
80106546:	6a 00                	push   $0x0
  pushl $39
80106548:	6a 27                	push   $0x27
  jmp alltraps
8010654a:	e9 f9 f7 ff ff       	jmp    80105d48 <alltraps>

8010654f <vector40>:
.globl vector40
vector40:
  pushl $0
8010654f:	6a 00                	push   $0x0
  pushl $40
80106551:	6a 28                	push   $0x28
  jmp alltraps
80106553:	e9 f0 f7 ff ff       	jmp    80105d48 <alltraps>

80106558 <vector41>:
.globl vector41
vector41:
  pushl $0
80106558:	6a 00                	push   $0x0
  pushl $41
8010655a:	6a 29                	push   $0x29
  jmp alltraps
8010655c:	e9 e7 f7 ff ff       	jmp    80105d48 <alltraps>

80106561 <vector42>:
.globl vector42
vector42:
  pushl $0
80106561:	6a 00                	push   $0x0
  pushl $42
80106563:	6a 2a                	push   $0x2a
  jmp alltraps
80106565:	e9 de f7 ff ff       	jmp    80105d48 <alltraps>

8010656a <vector43>:
.globl vector43
vector43:
  pushl $0
8010656a:	6a 00                	push   $0x0
  pushl $43
8010656c:	6a 2b                	push   $0x2b
  jmp alltraps
8010656e:	e9 d5 f7 ff ff       	jmp    80105d48 <alltraps>

80106573 <vector44>:
.globl vector44
vector44:
  pushl $0
80106573:	6a 00                	push   $0x0
  pushl $44
80106575:	6a 2c                	push   $0x2c
  jmp alltraps
80106577:	e9 cc f7 ff ff       	jmp    80105d48 <alltraps>

8010657c <vector45>:
.globl vector45
vector45:
  pushl $0
8010657c:	6a 00                	push   $0x0
  pushl $45
8010657e:	6a 2d                	push   $0x2d
  jmp alltraps
80106580:	e9 c3 f7 ff ff       	jmp    80105d48 <alltraps>

80106585 <vector46>:
.globl vector46
vector46:
  pushl $0
80106585:	6a 00                	push   $0x0
  pushl $46
80106587:	6a 2e                	push   $0x2e
  jmp alltraps
80106589:	e9 ba f7 ff ff       	jmp    80105d48 <alltraps>

8010658e <vector47>:
.globl vector47
vector47:
  pushl $0
8010658e:	6a 00                	push   $0x0
  pushl $47
80106590:	6a 2f                	push   $0x2f
  jmp alltraps
80106592:	e9 b1 f7 ff ff       	jmp    80105d48 <alltraps>

80106597 <vector48>:
.globl vector48
vector48:
  pushl $0
80106597:	6a 00                	push   $0x0
  pushl $48
80106599:	6a 30                	push   $0x30
  jmp alltraps
8010659b:	e9 a8 f7 ff ff       	jmp    80105d48 <alltraps>

801065a0 <vector49>:
.globl vector49
vector49:
  pushl $0
801065a0:	6a 00                	push   $0x0
  pushl $49
801065a2:	6a 31                	push   $0x31
  jmp alltraps
801065a4:	e9 9f f7 ff ff       	jmp    80105d48 <alltraps>

801065a9 <vector50>:
.globl vector50
vector50:
  pushl $0
801065a9:	6a 00                	push   $0x0
  pushl $50
801065ab:	6a 32                	push   $0x32
  jmp alltraps
801065ad:	e9 96 f7 ff ff       	jmp    80105d48 <alltraps>

801065b2 <vector51>:
.globl vector51
vector51:
  pushl $0
801065b2:	6a 00                	push   $0x0
  pushl $51
801065b4:	6a 33                	push   $0x33
  jmp alltraps
801065b6:	e9 8d f7 ff ff       	jmp    80105d48 <alltraps>

801065bb <vector52>:
.globl vector52
vector52:
  pushl $0
801065bb:	6a 00                	push   $0x0
  pushl $52
801065bd:	6a 34                	push   $0x34
  jmp alltraps
801065bf:	e9 84 f7 ff ff       	jmp    80105d48 <alltraps>

801065c4 <vector53>:
.globl vector53
vector53:
  pushl $0
801065c4:	6a 00                	push   $0x0
  pushl $53
801065c6:	6a 35                	push   $0x35
  jmp alltraps
801065c8:	e9 7b f7 ff ff       	jmp    80105d48 <alltraps>

801065cd <vector54>:
.globl vector54
vector54:
  pushl $0
801065cd:	6a 00                	push   $0x0
  pushl $54
801065cf:	6a 36                	push   $0x36
  jmp alltraps
801065d1:	e9 72 f7 ff ff       	jmp    80105d48 <alltraps>

801065d6 <vector55>:
.globl vector55
vector55:
  pushl $0
801065d6:	6a 00                	push   $0x0
  pushl $55
801065d8:	6a 37                	push   $0x37
  jmp alltraps
801065da:	e9 69 f7 ff ff       	jmp    80105d48 <alltraps>

801065df <vector56>:
.globl vector56
vector56:
  pushl $0
801065df:	6a 00                	push   $0x0
  pushl $56
801065e1:	6a 38                	push   $0x38
  jmp alltraps
801065e3:	e9 60 f7 ff ff       	jmp    80105d48 <alltraps>

801065e8 <vector57>:
.globl vector57
vector57:
  pushl $0
801065e8:	6a 00                	push   $0x0
  pushl $57
801065ea:	6a 39                	push   $0x39
  jmp alltraps
801065ec:	e9 57 f7 ff ff       	jmp    80105d48 <alltraps>

801065f1 <vector58>:
.globl vector58
vector58:
  pushl $0
801065f1:	6a 00                	push   $0x0
  pushl $58
801065f3:	6a 3a                	push   $0x3a
  jmp alltraps
801065f5:	e9 4e f7 ff ff       	jmp    80105d48 <alltraps>

801065fa <vector59>:
.globl vector59
vector59:
  pushl $0
801065fa:	6a 00                	push   $0x0
  pushl $59
801065fc:	6a 3b                	push   $0x3b
  jmp alltraps
801065fe:	e9 45 f7 ff ff       	jmp    80105d48 <alltraps>

80106603 <vector60>:
.globl vector60
vector60:
  pushl $0
80106603:	6a 00                	push   $0x0
  pushl $60
80106605:	6a 3c                	push   $0x3c
  jmp alltraps
80106607:	e9 3c f7 ff ff       	jmp    80105d48 <alltraps>

8010660c <vector61>:
.globl vector61
vector61:
  pushl $0
8010660c:	6a 00                	push   $0x0
  pushl $61
8010660e:	6a 3d                	push   $0x3d
  jmp alltraps
80106610:	e9 33 f7 ff ff       	jmp    80105d48 <alltraps>

80106615 <vector62>:
.globl vector62
vector62:
  pushl $0
80106615:	6a 00                	push   $0x0
  pushl $62
80106617:	6a 3e                	push   $0x3e
  jmp alltraps
80106619:	e9 2a f7 ff ff       	jmp    80105d48 <alltraps>

8010661e <vector63>:
.globl vector63
vector63:
  pushl $0
8010661e:	6a 00                	push   $0x0
  pushl $63
80106620:	6a 3f                	push   $0x3f
  jmp alltraps
80106622:	e9 21 f7 ff ff       	jmp    80105d48 <alltraps>

80106627 <vector64>:
.globl vector64
vector64:
  pushl $0
80106627:	6a 00                	push   $0x0
  pushl $64
80106629:	6a 40                	push   $0x40
  jmp alltraps
8010662b:	e9 18 f7 ff ff       	jmp    80105d48 <alltraps>

80106630 <vector65>:
.globl vector65
vector65:
  pushl $0
80106630:	6a 00                	push   $0x0
  pushl $65
80106632:	6a 41                	push   $0x41
  jmp alltraps
80106634:	e9 0f f7 ff ff       	jmp    80105d48 <alltraps>

80106639 <vector66>:
.globl vector66
vector66:
  pushl $0
80106639:	6a 00                	push   $0x0
  pushl $66
8010663b:	6a 42                	push   $0x42
  jmp alltraps
8010663d:	e9 06 f7 ff ff       	jmp    80105d48 <alltraps>

80106642 <vector67>:
.globl vector67
vector67:
  pushl $0
80106642:	6a 00                	push   $0x0
  pushl $67
80106644:	6a 43                	push   $0x43
  jmp alltraps
80106646:	e9 fd f6 ff ff       	jmp    80105d48 <alltraps>

8010664b <vector68>:
.globl vector68
vector68:
  pushl $0
8010664b:	6a 00                	push   $0x0
  pushl $68
8010664d:	6a 44                	push   $0x44
  jmp alltraps
8010664f:	e9 f4 f6 ff ff       	jmp    80105d48 <alltraps>

80106654 <vector69>:
.globl vector69
vector69:
  pushl $0
80106654:	6a 00                	push   $0x0
  pushl $69
80106656:	6a 45                	push   $0x45
  jmp alltraps
80106658:	e9 eb f6 ff ff       	jmp    80105d48 <alltraps>

8010665d <vector70>:
.globl vector70
vector70:
  pushl $0
8010665d:	6a 00                	push   $0x0
  pushl $70
8010665f:	6a 46                	push   $0x46
  jmp alltraps
80106661:	e9 e2 f6 ff ff       	jmp    80105d48 <alltraps>

80106666 <vector71>:
.globl vector71
vector71:
  pushl $0
80106666:	6a 00                	push   $0x0
  pushl $71
80106668:	6a 47                	push   $0x47
  jmp alltraps
8010666a:	e9 d9 f6 ff ff       	jmp    80105d48 <alltraps>

8010666f <vector72>:
.globl vector72
vector72:
  pushl $0
8010666f:	6a 00                	push   $0x0
  pushl $72
80106671:	6a 48                	push   $0x48
  jmp alltraps
80106673:	e9 d0 f6 ff ff       	jmp    80105d48 <alltraps>

80106678 <vector73>:
.globl vector73
vector73:
  pushl $0
80106678:	6a 00                	push   $0x0
  pushl $73
8010667a:	6a 49                	push   $0x49
  jmp alltraps
8010667c:	e9 c7 f6 ff ff       	jmp    80105d48 <alltraps>

80106681 <vector74>:
.globl vector74
vector74:
  pushl $0
80106681:	6a 00                	push   $0x0
  pushl $74
80106683:	6a 4a                	push   $0x4a
  jmp alltraps
80106685:	e9 be f6 ff ff       	jmp    80105d48 <alltraps>

8010668a <vector75>:
.globl vector75
vector75:
  pushl $0
8010668a:	6a 00                	push   $0x0
  pushl $75
8010668c:	6a 4b                	push   $0x4b
  jmp alltraps
8010668e:	e9 b5 f6 ff ff       	jmp    80105d48 <alltraps>

80106693 <vector76>:
.globl vector76
vector76:
  pushl $0
80106693:	6a 00                	push   $0x0
  pushl $76
80106695:	6a 4c                	push   $0x4c
  jmp alltraps
80106697:	e9 ac f6 ff ff       	jmp    80105d48 <alltraps>

8010669c <vector77>:
.globl vector77
vector77:
  pushl $0
8010669c:	6a 00                	push   $0x0
  pushl $77
8010669e:	6a 4d                	push   $0x4d
  jmp alltraps
801066a0:	e9 a3 f6 ff ff       	jmp    80105d48 <alltraps>

801066a5 <vector78>:
.globl vector78
vector78:
  pushl $0
801066a5:	6a 00                	push   $0x0
  pushl $78
801066a7:	6a 4e                	push   $0x4e
  jmp alltraps
801066a9:	e9 9a f6 ff ff       	jmp    80105d48 <alltraps>

801066ae <vector79>:
.globl vector79
vector79:
  pushl $0
801066ae:	6a 00                	push   $0x0
  pushl $79
801066b0:	6a 4f                	push   $0x4f
  jmp alltraps
801066b2:	e9 91 f6 ff ff       	jmp    80105d48 <alltraps>

801066b7 <vector80>:
.globl vector80
vector80:
  pushl $0
801066b7:	6a 00                	push   $0x0
  pushl $80
801066b9:	6a 50                	push   $0x50
  jmp alltraps
801066bb:	e9 88 f6 ff ff       	jmp    80105d48 <alltraps>

801066c0 <vector81>:
.globl vector81
vector81:
  pushl $0
801066c0:	6a 00                	push   $0x0
  pushl $81
801066c2:	6a 51                	push   $0x51
  jmp alltraps
801066c4:	e9 7f f6 ff ff       	jmp    80105d48 <alltraps>

801066c9 <vector82>:
.globl vector82
vector82:
  pushl $0
801066c9:	6a 00                	push   $0x0
  pushl $82
801066cb:	6a 52                	push   $0x52
  jmp alltraps
801066cd:	e9 76 f6 ff ff       	jmp    80105d48 <alltraps>

801066d2 <vector83>:
.globl vector83
vector83:
  pushl $0
801066d2:	6a 00                	push   $0x0
  pushl $83
801066d4:	6a 53                	push   $0x53
  jmp alltraps
801066d6:	e9 6d f6 ff ff       	jmp    80105d48 <alltraps>

801066db <vector84>:
.globl vector84
vector84:
  pushl $0
801066db:	6a 00                	push   $0x0
  pushl $84
801066dd:	6a 54                	push   $0x54
  jmp alltraps
801066df:	e9 64 f6 ff ff       	jmp    80105d48 <alltraps>

801066e4 <vector85>:
.globl vector85
vector85:
  pushl $0
801066e4:	6a 00                	push   $0x0
  pushl $85
801066e6:	6a 55                	push   $0x55
  jmp alltraps
801066e8:	e9 5b f6 ff ff       	jmp    80105d48 <alltraps>

801066ed <vector86>:
.globl vector86
vector86:
  pushl $0
801066ed:	6a 00                	push   $0x0
  pushl $86
801066ef:	6a 56                	push   $0x56
  jmp alltraps
801066f1:	e9 52 f6 ff ff       	jmp    80105d48 <alltraps>

801066f6 <vector87>:
.globl vector87
vector87:
  pushl $0
801066f6:	6a 00                	push   $0x0
  pushl $87
801066f8:	6a 57                	push   $0x57
  jmp alltraps
801066fa:	e9 49 f6 ff ff       	jmp    80105d48 <alltraps>

801066ff <vector88>:
.globl vector88
vector88:
  pushl $0
801066ff:	6a 00                	push   $0x0
  pushl $88
80106701:	6a 58                	push   $0x58
  jmp alltraps
80106703:	e9 40 f6 ff ff       	jmp    80105d48 <alltraps>

80106708 <vector89>:
.globl vector89
vector89:
  pushl $0
80106708:	6a 00                	push   $0x0
  pushl $89
8010670a:	6a 59                	push   $0x59
  jmp alltraps
8010670c:	e9 37 f6 ff ff       	jmp    80105d48 <alltraps>

80106711 <vector90>:
.globl vector90
vector90:
  pushl $0
80106711:	6a 00                	push   $0x0
  pushl $90
80106713:	6a 5a                	push   $0x5a
  jmp alltraps
80106715:	e9 2e f6 ff ff       	jmp    80105d48 <alltraps>

8010671a <vector91>:
.globl vector91
vector91:
  pushl $0
8010671a:	6a 00                	push   $0x0
  pushl $91
8010671c:	6a 5b                	push   $0x5b
  jmp alltraps
8010671e:	e9 25 f6 ff ff       	jmp    80105d48 <alltraps>

80106723 <vector92>:
.globl vector92
vector92:
  pushl $0
80106723:	6a 00                	push   $0x0
  pushl $92
80106725:	6a 5c                	push   $0x5c
  jmp alltraps
80106727:	e9 1c f6 ff ff       	jmp    80105d48 <alltraps>

8010672c <vector93>:
.globl vector93
vector93:
  pushl $0
8010672c:	6a 00                	push   $0x0
  pushl $93
8010672e:	6a 5d                	push   $0x5d
  jmp alltraps
80106730:	e9 13 f6 ff ff       	jmp    80105d48 <alltraps>

80106735 <vector94>:
.globl vector94
vector94:
  pushl $0
80106735:	6a 00                	push   $0x0
  pushl $94
80106737:	6a 5e                	push   $0x5e
  jmp alltraps
80106739:	e9 0a f6 ff ff       	jmp    80105d48 <alltraps>

8010673e <vector95>:
.globl vector95
vector95:
  pushl $0
8010673e:	6a 00                	push   $0x0
  pushl $95
80106740:	6a 5f                	push   $0x5f
  jmp alltraps
80106742:	e9 01 f6 ff ff       	jmp    80105d48 <alltraps>

80106747 <vector96>:
.globl vector96
vector96:
  pushl $0
80106747:	6a 00                	push   $0x0
  pushl $96
80106749:	6a 60                	push   $0x60
  jmp alltraps
8010674b:	e9 f8 f5 ff ff       	jmp    80105d48 <alltraps>

80106750 <vector97>:
.globl vector97
vector97:
  pushl $0
80106750:	6a 00                	push   $0x0
  pushl $97
80106752:	6a 61                	push   $0x61
  jmp alltraps
80106754:	e9 ef f5 ff ff       	jmp    80105d48 <alltraps>

80106759 <vector98>:
.globl vector98
vector98:
  pushl $0
80106759:	6a 00                	push   $0x0
  pushl $98
8010675b:	6a 62                	push   $0x62
  jmp alltraps
8010675d:	e9 e6 f5 ff ff       	jmp    80105d48 <alltraps>

80106762 <vector99>:
.globl vector99
vector99:
  pushl $0
80106762:	6a 00                	push   $0x0
  pushl $99
80106764:	6a 63                	push   $0x63
  jmp alltraps
80106766:	e9 dd f5 ff ff       	jmp    80105d48 <alltraps>

8010676b <vector100>:
.globl vector100
vector100:
  pushl $0
8010676b:	6a 00                	push   $0x0
  pushl $100
8010676d:	6a 64                	push   $0x64
  jmp alltraps
8010676f:	e9 d4 f5 ff ff       	jmp    80105d48 <alltraps>

80106774 <vector101>:
.globl vector101
vector101:
  pushl $0
80106774:	6a 00                	push   $0x0
  pushl $101
80106776:	6a 65                	push   $0x65
  jmp alltraps
80106778:	e9 cb f5 ff ff       	jmp    80105d48 <alltraps>

8010677d <vector102>:
.globl vector102
vector102:
  pushl $0
8010677d:	6a 00                	push   $0x0
  pushl $102
8010677f:	6a 66                	push   $0x66
  jmp alltraps
80106781:	e9 c2 f5 ff ff       	jmp    80105d48 <alltraps>

80106786 <vector103>:
.globl vector103
vector103:
  pushl $0
80106786:	6a 00                	push   $0x0
  pushl $103
80106788:	6a 67                	push   $0x67
  jmp alltraps
8010678a:	e9 b9 f5 ff ff       	jmp    80105d48 <alltraps>

8010678f <vector104>:
.globl vector104
vector104:
  pushl $0
8010678f:	6a 00                	push   $0x0
  pushl $104
80106791:	6a 68                	push   $0x68
  jmp alltraps
80106793:	e9 b0 f5 ff ff       	jmp    80105d48 <alltraps>

80106798 <vector105>:
.globl vector105
vector105:
  pushl $0
80106798:	6a 00                	push   $0x0
  pushl $105
8010679a:	6a 69                	push   $0x69
  jmp alltraps
8010679c:	e9 a7 f5 ff ff       	jmp    80105d48 <alltraps>

801067a1 <vector106>:
.globl vector106
vector106:
  pushl $0
801067a1:	6a 00                	push   $0x0
  pushl $106
801067a3:	6a 6a                	push   $0x6a
  jmp alltraps
801067a5:	e9 9e f5 ff ff       	jmp    80105d48 <alltraps>

801067aa <vector107>:
.globl vector107
vector107:
  pushl $0
801067aa:	6a 00                	push   $0x0
  pushl $107
801067ac:	6a 6b                	push   $0x6b
  jmp alltraps
801067ae:	e9 95 f5 ff ff       	jmp    80105d48 <alltraps>

801067b3 <vector108>:
.globl vector108
vector108:
  pushl $0
801067b3:	6a 00                	push   $0x0
  pushl $108
801067b5:	6a 6c                	push   $0x6c
  jmp alltraps
801067b7:	e9 8c f5 ff ff       	jmp    80105d48 <alltraps>

801067bc <vector109>:
.globl vector109
vector109:
  pushl $0
801067bc:	6a 00                	push   $0x0
  pushl $109
801067be:	6a 6d                	push   $0x6d
  jmp alltraps
801067c0:	e9 83 f5 ff ff       	jmp    80105d48 <alltraps>

801067c5 <vector110>:
.globl vector110
vector110:
  pushl $0
801067c5:	6a 00                	push   $0x0
  pushl $110
801067c7:	6a 6e                	push   $0x6e
  jmp alltraps
801067c9:	e9 7a f5 ff ff       	jmp    80105d48 <alltraps>

801067ce <vector111>:
.globl vector111
vector111:
  pushl $0
801067ce:	6a 00                	push   $0x0
  pushl $111
801067d0:	6a 6f                	push   $0x6f
  jmp alltraps
801067d2:	e9 71 f5 ff ff       	jmp    80105d48 <alltraps>

801067d7 <vector112>:
.globl vector112
vector112:
  pushl $0
801067d7:	6a 00                	push   $0x0
  pushl $112
801067d9:	6a 70                	push   $0x70
  jmp alltraps
801067db:	e9 68 f5 ff ff       	jmp    80105d48 <alltraps>

801067e0 <vector113>:
.globl vector113
vector113:
  pushl $0
801067e0:	6a 00                	push   $0x0
  pushl $113
801067e2:	6a 71                	push   $0x71
  jmp alltraps
801067e4:	e9 5f f5 ff ff       	jmp    80105d48 <alltraps>

801067e9 <vector114>:
.globl vector114
vector114:
  pushl $0
801067e9:	6a 00                	push   $0x0
  pushl $114
801067eb:	6a 72                	push   $0x72
  jmp alltraps
801067ed:	e9 56 f5 ff ff       	jmp    80105d48 <alltraps>

801067f2 <vector115>:
.globl vector115
vector115:
  pushl $0
801067f2:	6a 00                	push   $0x0
  pushl $115
801067f4:	6a 73                	push   $0x73
  jmp alltraps
801067f6:	e9 4d f5 ff ff       	jmp    80105d48 <alltraps>

801067fb <vector116>:
.globl vector116
vector116:
  pushl $0
801067fb:	6a 00                	push   $0x0
  pushl $116
801067fd:	6a 74                	push   $0x74
  jmp alltraps
801067ff:	e9 44 f5 ff ff       	jmp    80105d48 <alltraps>

80106804 <vector117>:
.globl vector117
vector117:
  pushl $0
80106804:	6a 00                	push   $0x0
  pushl $117
80106806:	6a 75                	push   $0x75
  jmp alltraps
80106808:	e9 3b f5 ff ff       	jmp    80105d48 <alltraps>

8010680d <vector118>:
.globl vector118
vector118:
  pushl $0
8010680d:	6a 00                	push   $0x0
  pushl $118
8010680f:	6a 76                	push   $0x76
  jmp alltraps
80106811:	e9 32 f5 ff ff       	jmp    80105d48 <alltraps>

80106816 <vector119>:
.globl vector119
vector119:
  pushl $0
80106816:	6a 00                	push   $0x0
  pushl $119
80106818:	6a 77                	push   $0x77
  jmp alltraps
8010681a:	e9 29 f5 ff ff       	jmp    80105d48 <alltraps>

8010681f <vector120>:
.globl vector120
vector120:
  pushl $0
8010681f:	6a 00                	push   $0x0
  pushl $120
80106821:	6a 78                	push   $0x78
  jmp alltraps
80106823:	e9 20 f5 ff ff       	jmp    80105d48 <alltraps>

80106828 <vector121>:
.globl vector121
vector121:
  pushl $0
80106828:	6a 00                	push   $0x0
  pushl $121
8010682a:	6a 79                	push   $0x79
  jmp alltraps
8010682c:	e9 17 f5 ff ff       	jmp    80105d48 <alltraps>

80106831 <vector122>:
.globl vector122
vector122:
  pushl $0
80106831:	6a 00                	push   $0x0
  pushl $122
80106833:	6a 7a                	push   $0x7a
  jmp alltraps
80106835:	e9 0e f5 ff ff       	jmp    80105d48 <alltraps>

8010683a <vector123>:
.globl vector123
vector123:
  pushl $0
8010683a:	6a 00                	push   $0x0
  pushl $123
8010683c:	6a 7b                	push   $0x7b
  jmp alltraps
8010683e:	e9 05 f5 ff ff       	jmp    80105d48 <alltraps>

80106843 <vector124>:
.globl vector124
vector124:
  pushl $0
80106843:	6a 00                	push   $0x0
  pushl $124
80106845:	6a 7c                	push   $0x7c
  jmp alltraps
80106847:	e9 fc f4 ff ff       	jmp    80105d48 <alltraps>

8010684c <vector125>:
.globl vector125
vector125:
  pushl $0
8010684c:	6a 00                	push   $0x0
  pushl $125
8010684e:	6a 7d                	push   $0x7d
  jmp alltraps
80106850:	e9 f3 f4 ff ff       	jmp    80105d48 <alltraps>

80106855 <vector126>:
.globl vector126
vector126:
  pushl $0
80106855:	6a 00                	push   $0x0
  pushl $126
80106857:	6a 7e                	push   $0x7e
  jmp alltraps
80106859:	e9 ea f4 ff ff       	jmp    80105d48 <alltraps>

8010685e <vector127>:
.globl vector127
vector127:
  pushl $0
8010685e:	6a 00                	push   $0x0
  pushl $127
80106860:	6a 7f                	push   $0x7f
  jmp alltraps
80106862:	e9 e1 f4 ff ff       	jmp    80105d48 <alltraps>

80106867 <vector128>:
.globl vector128
vector128:
  pushl $0
80106867:	6a 00                	push   $0x0
  pushl $128
80106869:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010686e:	e9 d5 f4 ff ff       	jmp    80105d48 <alltraps>

80106873 <vector129>:
.globl vector129
vector129:
  pushl $0
80106873:	6a 00                	push   $0x0
  pushl $129
80106875:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010687a:	e9 c9 f4 ff ff       	jmp    80105d48 <alltraps>

8010687f <vector130>:
.globl vector130
vector130:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $130
80106881:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106886:	e9 bd f4 ff ff       	jmp    80105d48 <alltraps>

8010688b <vector131>:
.globl vector131
vector131:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $131
8010688d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106892:	e9 b1 f4 ff ff       	jmp    80105d48 <alltraps>

80106897 <vector132>:
.globl vector132
vector132:
  pushl $0
80106897:	6a 00                	push   $0x0
  pushl $132
80106899:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010689e:	e9 a5 f4 ff ff       	jmp    80105d48 <alltraps>

801068a3 <vector133>:
.globl vector133
vector133:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $133
801068a5:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801068aa:	e9 99 f4 ff ff       	jmp    80105d48 <alltraps>

801068af <vector134>:
.globl vector134
vector134:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $134
801068b1:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801068b6:	e9 8d f4 ff ff       	jmp    80105d48 <alltraps>

801068bb <vector135>:
.globl vector135
vector135:
  pushl $0
801068bb:	6a 00                	push   $0x0
  pushl $135
801068bd:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801068c2:	e9 81 f4 ff ff       	jmp    80105d48 <alltraps>

801068c7 <vector136>:
.globl vector136
vector136:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $136
801068c9:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801068ce:	e9 75 f4 ff ff       	jmp    80105d48 <alltraps>

801068d3 <vector137>:
.globl vector137
vector137:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $137
801068d5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801068da:	e9 69 f4 ff ff       	jmp    80105d48 <alltraps>

801068df <vector138>:
.globl vector138
vector138:
  pushl $0
801068df:	6a 00                	push   $0x0
  pushl $138
801068e1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801068e6:	e9 5d f4 ff ff       	jmp    80105d48 <alltraps>

801068eb <vector139>:
.globl vector139
vector139:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $139
801068ed:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801068f2:	e9 51 f4 ff ff       	jmp    80105d48 <alltraps>

801068f7 <vector140>:
.globl vector140
vector140:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $140
801068f9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801068fe:	e9 45 f4 ff ff       	jmp    80105d48 <alltraps>

80106903 <vector141>:
.globl vector141
vector141:
  pushl $0
80106903:	6a 00                	push   $0x0
  pushl $141
80106905:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010690a:	e9 39 f4 ff ff       	jmp    80105d48 <alltraps>

8010690f <vector142>:
.globl vector142
vector142:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $142
80106911:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106916:	e9 2d f4 ff ff       	jmp    80105d48 <alltraps>

8010691b <vector143>:
.globl vector143
vector143:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $143
8010691d:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106922:	e9 21 f4 ff ff       	jmp    80105d48 <alltraps>

80106927 <vector144>:
.globl vector144
vector144:
  pushl $0
80106927:	6a 00                	push   $0x0
  pushl $144
80106929:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010692e:	e9 15 f4 ff ff       	jmp    80105d48 <alltraps>

80106933 <vector145>:
.globl vector145
vector145:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $145
80106935:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010693a:	e9 09 f4 ff ff       	jmp    80105d48 <alltraps>

8010693f <vector146>:
.globl vector146
vector146:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $146
80106941:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106946:	e9 fd f3 ff ff       	jmp    80105d48 <alltraps>

8010694b <vector147>:
.globl vector147
vector147:
  pushl $0
8010694b:	6a 00                	push   $0x0
  pushl $147
8010694d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106952:	e9 f1 f3 ff ff       	jmp    80105d48 <alltraps>

80106957 <vector148>:
.globl vector148
vector148:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $148
80106959:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010695e:	e9 e5 f3 ff ff       	jmp    80105d48 <alltraps>

80106963 <vector149>:
.globl vector149
vector149:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $149
80106965:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010696a:	e9 d9 f3 ff ff       	jmp    80105d48 <alltraps>

8010696f <vector150>:
.globl vector150
vector150:
  pushl $0
8010696f:	6a 00                	push   $0x0
  pushl $150
80106971:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106976:	e9 cd f3 ff ff       	jmp    80105d48 <alltraps>

8010697b <vector151>:
.globl vector151
vector151:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $151
8010697d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106982:	e9 c1 f3 ff ff       	jmp    80105d48 <alltraps>

80106987 <vector152>:
.globl vector152
vector152:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $152
80106989:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010698e:	e9 b5 f3 ff ff       	jmp    80105d48 <alltraps>

80106993 <vector153>:
.globl vector153
vector153:
  pushl $0
80106993:	6a 00                	push   $0x0
  pushl $153
80106995:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010699a:	e9 a9 f3 ff ff       	jmp    80105d48 <alltraps>

8010699f <vector154>:
.globl vector154
vector154:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $154
801069a1:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801069a6:	e9 9d f3 ff ff       	jmp    80105d48 <alltraps>

801069ab <vector155>:
.globl vector155
vector155:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $155
801069ad:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801069b2:	e9 91 f3 ff ff       	jmp    80105d48 <alltraps>

801069b7 <vector156>:
.globl vector156
vector156:
  pushl $0
801069b7:	6a 00                	push   $0x0
  pushl $156
801069b9:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801069be:	e9 85 f3 ff ff       	jmp    80105d48 <alltraps>

801069c3 <vector157>:
.globl vector157
vector157:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $157
801069c5:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801069ca:	e9 79 f3 ff ff       	jmp    80105d48 <alltraps>

801069cf <vector158>:
.globl vector158
vector158:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $158
801069d1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801069d6:	e9 6d f3 ff ff       	jmp    80105d48 <alltraps>

801069db <vector159>:
.globl vector159
vector159:
  pushl $0
801069db:	6a 00                	push   $0x0
  pushl $159
801069dd:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801069e2:	e9 61 f3 ff ff       	jmp    80105d48 <alltraps>

801069e7 <vector160>:
.globl vector160
vector160:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $160
801069e9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801069ee:	e9 55 f3 ff ff       	jmp    80105d48 <alltraps>

801069f3 <vector161>:
.globl vector161
vector161:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $161
801069f5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801069fa:	e9 49 f3 ff ff       	jmp    80105d48 <alltraps>

801069ff <vector162>:
.globl vector162
vector162:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $162
80106a01:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106a06:	e9 3d f3 ff ff       	jmp    80105d48 <alltraps>

80106a0b <vector163>:
.globl vector163
vector163:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $163
80106a0d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106a12:	e9 31 f3 ff ff       	jmp    80105d48 <alltraps>

80106a17 <vector164>:
.globl vector164
vector164:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $164
80106a19:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106a1e:	e9 25 f3 ff ff       	jmp    80105d48 <alltraps>

80106a23 <vector165>:
.globl vector165
vector165:
  pushl $0
80106a23:	6a 00                	push   $0x0
  pushl $165
80106a25:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106a2a:	e9 19 f3 ff ff       	jmp    80105d48 <alltraps>

80106a2f <vector166>:
.globl vector166
vector166:
  pushl $0
80106a2f:	6a 00                	push   $0x0
  pushl $166
80106a31:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106a36:	e9 0d f3 ff ff       	jmp    80105d48 <alltraps>

80106a3b <vector167>:
.globl vector167
vector167:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $167
80106a3d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106a42:	e9 01 f3 ff ff       	jmp    80105d48 <alltraps>

80106a47 <vector168>:
.globl vector168
vector168:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $168
80106a49:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106a4e:	e9 f5 f2 ff ff       	jmp    80105d48 <alltraps>

80106a53 <vector169>:
.globl vector169
vector169:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $169
80106a55:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106a5a:	e9 e9 f2 ff ff       	jmp    80105d48 <alltraps>

80106a5f <vector170>:
.globl vector170
vector170:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $170
80106a61:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106a66:	e9 dd f2 ff ff       	jmp    80105d48 <alltraps>

80106a6b <vector171>:
.globl vector171
vector171:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $171
80106a6d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106a72:	e9 d1 f2 ff ff       	jmp    80105d48 <alltraps>

80106a77 <vector172>:
.globl vector172
vector172:
  pushl $0
80106a77:	6a 00                	push   $0x0
  pushl $172
80106a79:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106a7e:	e9 c5 f2 ff ff       	jmp    80105d48 <alltraps>

80106a83 <vector173>:
.globl vector173
vector173:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $173
80106a85:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106a8a:	e9 b9 f2 ff ff       	jmp    80105d48 <alltraps>

80106a8f <vector174>:
.globl vector174
vector174:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $174
80106a91:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106a96:	e9 ad f2 ff ff       	jmp    80105d48 <alltraps>

80106a9b <vector175>:
.globl vector175
vector175:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $175
80106a9d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106aa2:	e9 a1 f2 ff ff       	jmp    80105d48 <alltraps>

80106aa7 <vector176>:
.globl vector176
vector176:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $176
80106aa9:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106aae:	e9 95 f2 ff ff       	jmp    80105d48 <alltraps>

80106ab3 <vector177>:
.globl vector177
vector177:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $177
80106ab5:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106aba:	e9 89 f2 ff ff       	jmp    80105d48 <alltraps>

80106abf <vector178>:
.globl vector178
vector178:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $178
80106ac1:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106ac6:	e9 7d f2 ff ff       	jmp    80105d48 <alltraps>

80106acb <vector179>:
.globl vector179
vector179:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $179
80106acd:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106ad2:	e9 71 f2 ff ff       	jmp    80105d48 <alltraps>

80106ad7 <vector180>:
.globl vector180
vector180:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $180
80106ad9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106ade:	e9 65 f2 ff ff       	jmp    80105d48 <alltraps>

80106ae3 <vector181>:
.globl vector181
vector181:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $181
80106ae5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106aea:	e9 59 f2 ff ff       	jmp    80105d48 <alltraps>

80106aef <vector182>:
.globl vector182
vector182:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $182
80106af1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106af6:	e9 4d f2 ff ff       	jmp    80105d48 <alltraps>

80106afb <vector183>:
.globl vector183
vector183:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $183
80106afd:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106b02:	e9 41 f2 ff ff       	jmp    80105d48 <alltraps>

80106b07 <vector184>:
.globl vector184
vector184:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $184
80106b09:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106b0e:	e9 35 f2 ff ff       	jmp    80105d48 <alltraps>

80106b13 <vector185>:
.globl vector185
vector185:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $185
80106b15:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106b1a:	e9 29 f2 ff ff       	jmp    80105d48 <alltraps>

80106b1f <vector186>:
.globl vector186
vector186:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $186
80106b21:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106b26:	e9 1d f2 ff ff       	jmp    80105d48 <alltraps>

80106b2b <vector187>:
.globl vector187
vector187:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $187
80106b2d:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106b32:	e9 11 f2 ff ff       	jmp    80105d48 <alltraps>

80106b37 <vector188>:
.globl vector188
vector188:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $188
80106b39:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106b3e:	e9 05 f2 ff ff       	jmp    80105d48 <alltraps>

80106b43 <vector189>:
.globl vector189
vector189:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $189
80106b45:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106b4a:	e9 f9 f1 ff ff       	jmp    80105d48 <alltraps>

80106b4f <vector190>:
.globl vector190
vector190:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $190
80106b51:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106b56:	e9 ed f1 ff ff       	jmp    80105d48 <alltraps>

80106b5b <vector191>:
.globl vector191
vector191:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $191
80106b5d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106b62:	e9 e1 f1 ff ff       	jmp    80105d48 <alltraps>

80106b67 <vector192>:
.globl vector192
vector192:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $192
80106b69:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106b6e:	e9 d5 f1 ff ff       	jmp    80105d48 <alltraps>

80106b73 <vector193>:
.globl vector193
vector193:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $193
80106b75:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106b7a:	e9 c9 f1 ff ff       	jmp    80105d48 <alltraps>

80106b7f <vector194>:
.globl vector194
vector194:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $194
80106b81:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106b86:	e9 bd f1 ff ff       	jmp    80105d48 <alltraps>

80106b8b <vector195>:
.globl vector195
vector195:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $195
80106b8d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106b92:	e9 b1 f1 ff ff       	jmp    80105d48 <alltraps>

80106b97 <vector196>:
.globl vector196
vector196:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $196
80106b99:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106b9e:	e9 a5 f1 ff ff       	jmp    80105d48 <alltraps>

80106ba3 <vector197>:
.globl vector197
vector197:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $197
80106ba5:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106baa:	e9 99 f1 ff ff       	jmp    80105d48 <alltraps>

80106baf <vector198>:
.globl vector198
vector198:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $198
80106bb1:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106bb6:	e9 8d f1 ff ff       	jmp    80105d48 <alltraps>

80106bbb <vector199>:
.globl vector199
vector199:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $199
80106bbd:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106bc2:	e9 81 f1 ff ff       	jmp    80105d48 <alltraps>

80106bc7 <vector200>:
.globl vector200
vector200:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $200
80106bc9:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106bce:	e9 75 f1 ff ff       	jmp    80105d48 <alltraps>

80106bd3 <vector201>:
.globl vector201
vector201:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $201
80106bd5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106bda:	e9 69 f1 ff ff       	jmp    80105d48 <alltraps>

80106bdf <vector202>:
.globl vector202
vector202:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $202
80106be1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106be6:	e9 5d f1 ff ff       	jmp    80105d48 <alltraps>

80106beb <vector203>:
.globl vector203
vector203:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $203
80106bed:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106bf2:	e9 51 f1 ff ff       	jmp    80105d48 <alltraps>

80106bf7 <vector204>:
.globl vector204
vector204:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $204
80106bf9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106bfe:	e9 45 f1 ff ff       	jmp    80105d48 <alltraps>

80106c03 <vector205>:
.globl vector205
vector205:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $205
80106c05:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106c0a:	e9 39 f1 ff ff       	jmp    80105d48 <alltraps>

80106c0f <vector206>:
.globl vector206
vector206:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $206
80106c11:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106c16:	e9 2d f1 ff ff       	jmp    80105d48 <alltraps>

80106c1b <vector207>:
.globl vector207
vector207:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $207
80106c1d:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106c22:	e9 21 f1 ff ff       	jmp    80105d48 <alltraps>

80106c27 <vector208>:
.globl vector208
vector208:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $208
80106c29:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106c2e:	e9 15 f1 ff ff       	jmp    80105d48 <alltraps>

80106c33 <vector209>:
.globl vector209
vector209:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $209
80106c35:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106c3a:	e9 09 f1 ff ff       	jmp    80105d48 <alltraps>

80106c3f <vector210>:
.globl vector210
vector210:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $210
80106c41:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106c46:	e9 fd f0 ff ff       	jmp    80105d48 <alltraps>

80106c4b <vector211>:
.globl vector211
vector211:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $211
80106c4d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106c52:	e9 f1 f0 ff ff       	jmp    80105d48 <alltraps>

80106c57 <vector212>:
.globl vector212
vector212:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $212
80106c59:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106c5e:	e9 e5 f0 ff ff       	jmp    80105d48 <alltraps>

80106c63 <vector213>:
.globl vector213
vector213:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $213
80106c65:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106c6a:	e9 d9 f0 ff ff       	jmp    80105d48 <alltraps>

80106c6f <vector214>:
.globl vector214
vector214:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $214
80106c71:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106c76:	e9 cd f0 ff ff       	jmp    80105d48 <alltraps>

80106c7b <vector215>:
.globl vector215
vector215:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $215
80106c7d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106c82:	e9 c1 f0 ff ff       	jmp    80105d48 <alltraps>

80106c87 <vector216>:
.globl vector216
vector216:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $216
80106c89:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106c8e:	e9 b5 f0 ff ff       	jmp    80105d48 <alltraps>

80106c93 <vector217>:
.globl vector217
vector217:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $217
80106c95:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106c9a:	e9 a9 f0 ff ff       	jmp    80105d48 <alltraps>

80106c9f <vector218>:
.globl vector218
vector218:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $218
80106ca1:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106ca6:	e9 9d f0 ff ff       	jmp    80105d48 <alltraps>

80106cab <vector219>:
.globl vector219
vector219:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $219
80106cad:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106cb2:	e9 91 f0 ff ff       	jmp    80105d48 <alltraps>

80106cb7 <vector220>:
.globl vector220
vector220:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $220
80106cb9:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106cbe:	e9 85 f0 ff ff       	jmp    80105d48 <alltraps>

80106cc3 <vector221>:
.globl vector221
vector221:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $221
80106cc5:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106cca:	e9 79 f0 ff ff       	jmp    80105d48 <alltraps>

80106ccf <vector222>:
.globl vector222
vector222:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $222
80106cd1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106cd6:	e9 6d f0 ff ff       	jmp    80105d48 <alltraps>

80106cdb <vector223>:
.globl vector223
vector223:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $223
80106cdd:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106ce2:	e9 61 f0 ff ff       	jmp    80105d48 <alltraps>

80106ce7 <vector224>:
.globl vector224
vector224:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $224
80106ce9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106cee:	e9 55 f0 ff ff       	jmp    80105d48 <alltraps>

80106cf3 <vector225>:
.globl vector225
vector225:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $225
80106cf5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106cfa:	e9 49 f0 ff ff       	jmp    80105d48 <alltraps>

80106cff <vector226>:
.globl vector226
vector226:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $226
80106d01:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106d06:	e9 3d f0 ff ff       	jmp    80105d48 <alltraps>

80106d0b <vector227>:
.globl vector227
vector227:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $227
80106d0d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106d12:	e9 31 f0 ff ff       	jmp    80105d48 <alltraps>

80106d17 <vector228>:
.globl vector228
vector228:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $228
80106d19:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106d1e:	e9 25 f0 ff ff       	jmp    80105d48 <alltraps>

80106d23 <vector229>:
.globl vector229
vector229:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $229
80106d25:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106d2a:	e9 19 f0 ff ff       	jmp    80105d48 <alltraps>

80106d2f <vector230>:
.globl vector230
vector230:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $230
80106d31:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106d36:	e9 0d f0 ff ff       	jmp    80105d48 <alltraps>

80106d3b <vector231>:
.globl vector231
vector231:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $231
80106d3d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106d42:	e9 01 f0 ff ff       	jmp    80105d48 <alltraps>

80106d47 <vector232>:
.globl vector232
vector232:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $232
80106d49:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106d4e:	e9 f5 ef ff ff       	jmp    80105d48 <alltraps>

80106d53 <vector233>:
.globl vector233
vector233:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $233
80106d55:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106d5a:	e9 e9 ef ff ff       	jmp    80105d48 <alltraps>

80106d5f <vector234>:
.globl vector234
vector234:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $234
80106d61:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106d66:	e9 dd ef ff ff       	jmp    80105d48 <alltraps>

80106d6b <vector235>:
.globl vector235
vector235:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $235
80106d6d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106d72:	e9 d1 ef ff ff       	jmp    80105d48 <alltraps>

80106d77 <vector236>:
.globl vector236
vector236:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $236
80106d79:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106d7e:	e9 c5 ef ff ff       	jmp    80105d48 <alltraps>

80106d83 <vector237>:
.globl vector237
vector237:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $237
80106d85:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106d8a:	e9 b9 ef ff ff       	jmp    80105d48 <alltraps>

80106d8f <vector238>:
.globl vector238
vector238:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $238
80106d91:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106d96:	e9 ad ef ff ff       	jmp    80105d48 <alltraps>

80106d9b <vector239>:
.globl vector239
vector239:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $239
80106d9d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106da2:	e9 a1 ef ff ff       	jmp    80105d48 <alltraps>

80106da7 <vector240>:
.globl vector240
vector240:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $240
80106da9:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106dae:	e9 95 ef ff ff       	jmp    80105d48 <alltraps>

80106db3 <vector241>:
.globl vector241
vector241:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $241
80106db5:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106dba:	e9 89 ef ff ff       	jmp    80105d48 <alltraps>

80106dbf <vector242>:
.globl vector242
vector242:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $242
80106dc1:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106dc6:	e9 7d ef ff ff       	jmp    80105d48 <alltraps>

80106dcb <vector243>:
.globl vector243
vector243:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $243
80106dcd:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106dd2:	e9 71 ef ff ff       	jmp    80105d48 <alltraps>

80106dd7 <vector244>:
.globl vector244
vector244:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $244
80106dd9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106dde:	e9 65 ef ff ff       	jmp    80105d48 <alltraps>

80106de3 <vector245>:
.globl vector245
vector245:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $245
80106de5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106dea:	e9 59 ef ff ff       	jmp    80105d48 <alltraps>

80106def <vector246>:
.globl vector246
vector246:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $246
80106df1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106df6:	e9 4d ef ff ff       	jmp    80105d48 <alltraps>

80106dfb <vector247>:
.globl vector247
vector247:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $247
80106dfd:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106e02:	e9 41 ef ff ff       	jmp    80105d48 <alltraps>

80106e07 <vector248>:
.globl vector248
vector248:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $248
80106e09:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106e0e:	e9 35 ef ff ff       	jmp    80105d48 <alltraps>

80106e13 <vector249>:
.globl vector249
vector249:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $249
80106e15:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106e1a:	e9 29 ef ff ff       	jmp    80105d48 <alltraps>

80106e1f <vector250>:
.globl vector250
vector250:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $250
80106e21:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106e26:	e9 1d ef ff ff       	jmp    80105d48 <alltraps>

80106e2b <vector251>:
.globl vector251
vector251:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $251
80106e2d:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106e32:	e9 11 ef ff ff       	jmp    80105d48 <alltraps>

80106e37 <vector252>:
.globl vector252
vector252:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $252
80106e39:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106e3e:	e9 05 ef ff ff       	jmp    80105d48 <alltraps>

80106e43 <vector253>:
.globl vector253
vector253:
  pushl $0
80106e43:	6a 00                	push   $0x0
  pushl $253
80106e45:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106e4a:	e9 f9 ee ff ff       	jmp    80105d48 <alltraps>

80106e4f <vector254>:
.globl vector254
vector254:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $254
80106e51:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106e56:	e9 ed ee ff ff       	jmp    80105d48 <alltraps>

80106e5b <vector255>:
.globl vector255
vector255:
  pushl $0
80106e5b:	6a 00                	push   $0x0
  pushl $255
80106e5d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106e62:	e9 e1 ee ff ff       	jmp    80105d48 <alltraps>

80106e67 <lgdt>:
{
80106e67:	55                   	push   %ebp
80106e68:	89 e5                	mov    %esp,%ebp
80106e6a:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e70:	83 e8 01             	sub    $0x1,%eax
80106e73:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e77:	8b 45 08             	mov    0x8(%ebp),%eax
80106e7a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e81:	c1 e8 10             	shr    $0x10,%eax
80106e84:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106e88:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e8b:	0f 01 10             	lgdtl  (%eax)
}
80106e8e:	90                   	nop
80106e8f:	c9                   	leave
80106e90:	c3                   	ret

80106e91 <ltr>:
{
80106e91:	55                   	push   %ebp
80106e92:	89 e5                	mov    %esp,%ebp
80106e94:	83 ec 04             	sub    $0x4,%esp
80106e97:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106e9e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106ea2:	0f 00 d8             	ltr    %eax
}
80106ea5:	90                   	nop
80106ea6:	c9                   	leave
80106ea7:	c3                   	ret

80106ea8 <lcr3>:

static inline void
lcr3(uint val)
{
80106ea8:	55                   	push   %ebp
80106ea9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106eab:	8b 45 08             	mov    0x8(%ebp),%eax
80106eae:	0f 22 d8             	mov    %eax,%cr3
}
80106eb1:	90                   	nop
80106eb2:	5d                   	pop    %ebp
80106eb3:	c3                   	ret

80106eb4 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106eb4:	55                   	push   %ebp
80106eb5:	89 e5                	mov    %esp,%ebp
80106eb7:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106eba:	e8 de ca ff ff       	call   8010399d <cpuid>
80106ebf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106ec5:	05 80 6a 19 80       	add    $0x80196a80,%eax
80106eca:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed0:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed9:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee2:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106eed:	83 e2 f0             	and    $0xfffffff0,%edx
80106ef0:	83 ca 0a             	or     $0xa,%edx
80106ef3:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106efd:	83 ca 10             	or     $0x10,%edx
80106f00:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f06:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f0a:	83 e2 9f             	and    $0xffffff9f,%edx
80106f0d:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f13:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106f17:	83 ca 80             	or     $0xffffff80,%edx
80106f1a:	88 50 7d             	mov    %dl,0x7d(%eax)
80106f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f20:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f24:	83 ca 0f             	or     $0xf,%edx
80106f27:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f2d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f31:	83 e2 ef             	and    $0xffffffef,%edx
80106f34:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f3a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f3e:	83 e2 df             	and    $0xffffffdf,%edx
80106f41:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f47:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f4b:	83 ca 40             	or     $0x40,%edx
80106f4e:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f54:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f58:	83 ca 80             	or     $0xffffff80,%edx
80106f5b:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f61:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f68:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106f6f:	ff ff 
80106f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f74:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106f7b:	00 00 
80106f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f80:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80106f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f91:	83 e2 f0             	and    $0xfffffff0,%edx
80106f94:	83 ca 02             	or     $0x2,%edx
80106f97:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106fa7:	83 ca 10             	or     $0x10,%edx
80106faa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106fba:	83 e2 9f             	and    $0xffffff9f,%edx
80106fbd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106fcd:	83 ca 80             	or     $0xffffff80,%edx
80106fd0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fe0:	83 ca 0f             	or     $0xf,%edx
80106fe3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fec:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106ff3:	83 e2 ef             	and    $0xffffffef,%edx
80106ff6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fff:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107006:	83 e2 df             	and    $0xffffffdf,%edx
80107009:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010700f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107012:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107019:	83 ca 40             	or     $0x40,%edx
8010701c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107025:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010702c:	83 ca 80             	or     $0xffffff80,%edx
8010702f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107038:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010703f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107042:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107049:	ff ff 
8010704b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010704e:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107055:	00 00 
80107057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705a:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107064:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010706b:	83 e2 f0             	and    $0xfffffff0,%edx
8010706e:	83 ca 0a             	or     $0xa,%edx
80107071:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107081:	83 ca 10             	or     $0x10,%edx
80107084:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010708a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107094:	83 ca 60             	or     $0x60,%edx
80107097:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010709d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801070a7:	83 ca 80             	or     $0xffffff80,%edx
801070aa:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801070b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070ba:	83 ca 0f             	or     $0xf,%edx
801070bd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070cd:	83 e2 ef             	and    $0xffffffef,%edx
801070d0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070e0:	83 e2 df             	and    $0xffffffdf,%edx
801070e3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ec:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070f3:	83 ca 40             	or     $0x40,%edx
801070f6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ff:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107106:	83 ca 80             	or     $0xffffff80,%edx
80107109:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010710f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107112:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107123:	ff ff 
80107125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107128:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010712f:	00 00 
80107131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107134:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010713b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010713e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107145:	83 e2 f0             	and    $0xfffffff0,%edx
80107148:	83 ca 02             	or     $0x2,%edx
8010714b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107154:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010715b:	83 ca 10             	or     $0x10,%edx
8010715e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107167:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010716e:	83 ca 60             	or     $0x60,%edx
80107171:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010717a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107181:	83 ca 80             	or     $0xffffff80,%edx
80107184:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010718a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010718d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107194:	83 ca 0f             	or     $0xf,%edx
80107197:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010719d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071a7:	83 e2 ef             	and    $0xffffffef,%edx
801071aa:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071ba:	83 e2 df             	and    $0xffffffdf,%edx
801071bd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071cd:	83 ca 40             	or     $0x40,%edx
801071d0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071e0:	83 ca 80             	or     $0xffffff80,%edx
801071e3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ec:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801071f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f6:	83 c0 70             	add    $0x70,%eax
801071f9:	83 ec 08             	sub    $0x8,%esp
801071fc:	6a 30                	push   $0x30
801071fe:	50                   	push   %eax
801071ff:	e8 63 fc ff ff       	call   80106e67 <lgdt>
80107204:	83 c4 10             	add    $0x10,%esp
}
80107207:	90                   	nop
80107208:	c9                   	leave
80107209:	c3                   	ret

8010720a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010720a:	55                   	push   %ebp
8010720b:	89 e5                	mov    %esp,%ebp
8010720d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107210:	8b 45 0c             	mov    0xc(%ebp),%eax
80107213:	c1 e8 16             	shr    $0x16,%eax
80107216:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010721d:	8b 45 08             	mov    0x8(%ebp),%eax
80107220:	01 d0                	add    %edx,%eax
80107222:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107225:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107228:	8b 00                	mov    (%eax),%eax
8010722a:	83 e0 01             	and    $0x1,%eax
8010722d:	85 c0                	test   %eax,%eax
8010722f:	74 14                	je     80107245 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107231:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107234:	8b 00                	mov    (%eax),%eax
80107236:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010723b:	05 00 00 00 80       	add    $0x80000000,%eax
80107240:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107243:	eb 42                	jmp    80107287 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107249:	74 0e                	je     80107259 <walkpgdir+0x4f>
8010724b:	e8 58 b5 ff ff       	call   801027a8 <kalloc>
80107250:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107253:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107257:	75 07                	jne    80107260 <walkpgdir+0x56>
      return 0;
80107259:	b8 00 00 00 00       	mov    $0x0,%eax
8010725e:	eb 3e                	jmp    8010729e <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107260:	83 ec 04             	sub    $0x4,%esp
80107263:	68 00 10 00 00       	push   $0x1000
80107268:	6a 00                	push   $0x0
8010726a:	ff 75 f4             	push   -0xc(%ebp)
8010726d:	e8 29 d7 ff ff       	call   8010499b <memset>
80107272:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107278:	05 00 00 00 80       	add    $0x80000000,%eax
8010727d:	83 c8 07             	or     $0x7,%eax
80107280:	89 c2                	mov    %eax,%edx
80107282:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107285:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107287:	8b 45 0c             	mov    0xc(%ebp),%eax
8010728a:	c1 e8 0c             	shr    $0xc,%eax
8010728d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107292:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729c:	01 d0                	add    %edx,%eax
}
8010729e:	c9                   	leave
8010729f:	c3                   	ret

801072a0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801072a0:	55                   	push   %ebp
801072a1:	89 e5                	mov    %esp,%ebp
801072a3:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801072a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801072a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801072b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801072b4:	8b 45 10             	mov    0x10(%ebp),%eax
801072b7:	01 d0                	add    %edx,%eax
801072b9:	83 e8 01             	sub    $0x1,%eax
801072bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801072c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801072c4:	83 ec 04             	sub    $0x4,%esp
801072c7:	6a 01                	push   $0x1
801072c9:	ff 75 f4             	push   -0xc(%ebp)
801072cc:	ff 75 08             	push   0x8(%ebp)
801072cf:	e8 36 ff ff ff       	call   8010720a <walkpgdir>
801072d4:	83 c4 10             	add    $0x10,%esp
801072d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801072da:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801072de:	75 07                	jne    801072e7 <mappages+0x47>
      return -1;
801072e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072e5:	eb 47                	jmp    8010732e <mappages+0x8e>
    if(*pte & PTE_P)
801072e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072ea:	8b 00                	mov    (%eax),%eax
801072ec:	83 e0 01             	and    $0x1,%eax
801072ef:	85 c0                	test   %eax,%eax
801072f1:	74 0d                	je     80107300 <mappages+0x60>
      panic("remap");
801072f3:	83 ec 0c             	sub    $0xc,%esp
801072f6:	68 d4 a5 10 80       	push   $0x8010a5d4
801072fb:	e8 a9 92 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
80107300:	8b 45 18             	mov    0x18(%ebp),%eax
80107303:	0b 45 14             	or     0x14(%ebp),%eax
80107306:	83 c8 01             	or     $0x1,%eax
80107309:	89 c2                	mov    %eax,%edx
8010730b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010730e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107313:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107316:	74 10                	je     80107328 <mappages+0x88>
      break;
    a += PGSIZE;
80107318:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010731f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107326:	eb 9c                	jmp    801072c4 <mappages+0x24>
      break;
80107328:	90                   	nop
  }
  return 0;
80107329:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010732e:	c9                   	leave
8010732f:	c3                   	ret

80107330 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107330:	55                   	push   %ebp
80107331:	89 e5                	mov    %esp,%ebp
80107333:	53                   	push   %ebx
80107334:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107337:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
8010733e:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107343:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107348:	29 c2                	sub    %eax,%edx
8010734a:	89 d0                	mov    %edx,%eax
8010734c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010734f:	a1 48 6d 19 80       	mov    0x80196d48,%eax
80107354:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107357:	8b 15 48 6d 19 80    	mov    0x80196d48,%edx
8010735d:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107362:	01 d0                	add    %edx,%eax
80107364:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107367:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
8010736e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107371:	83 c0 30             	add    $0x30,%eax
80107374:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107377:	89 10                	mov    %edx,(%eax)
80107379:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010737c:	89 50 04             	mov    %edx,0x4(%eax)
8010737f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107382:	89 50 08             	mov    %edx,0x8(%eax)
80107385:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107388:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010738b:	e8 18 b4 ff ff       	call   801027a8 <kalloc>
80107390:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107393:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107397:	75 07                	jne    801073a0 <setupkvm+0x70>
    return 0;
80107399:	b8 00 00 00 00       	mov    $0x0,%eax
8010739e:	eb 78                	jmp    80107418 <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
801073a0:	83 ec 04             	sub    $0x4,%esp
801073a3:	68 00 10 00 00       	push   $0x1000
801073a8:	6a 00                	push   $0x0
801073aa:	ff 75 f0             	push   -0x10(%ebp)
801073ad:	e8 e9 d5 ff ff       	call   8010499b <memset>
801073b2:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801073b5:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
801073bc:	eb 4e                	jmp    8010740c <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801073be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c1:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801073c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c7:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801073ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cd:	8b 58 08             	mov    0x8(%eax),%ebx
801073d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d3:	8b 40 04             	mov    0x4(%eax),%eax
801073d6:	29 c3                	sub    %eax,%ebx
801073d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073db:	8b 00                	mov    (%eax),%eax
801073dd:	83 ec 0c             	sub    $0xc,%esp
801073e0:	51                   	push   %ecx
801073e1:	52                   	push   %edx
801073e2:	53                   	push   %ebx
801073e3:	50                   	push   %eax
801073e4:	ff 75 f0             	push   -0x10(%ebp)
801073e7:	e8 b4 fe ff ff       	call   801072a0 <mappages>
801073ec:	83 c4 20             	add    $0x20,%esp
801073ef:	85 c0                	test   %eax,%eax
801073f1:	79 15                	jns    80107408 <setupkvm+0xd8>
      freevm(pgdir);
801073f3:	83 ec 0c             	sub    $0xc,%esp
801073f6:	ff 75 f0             	push   -0x10(%ebp)
801073f9:	e8 f5 04 00 00       	call   801078f3 <freevm>
801073fe:	83 c4 10             	add    $0x10,%esp
      return 0;
80107401:	b8 00 00 00 00       	mov    $0x0,%eax
80107406:	eb 10                	jmp    80107418 <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107408:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010740c:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
80107413:	72 a9                	jb     801073be <setupkvm+0x8e>
    }
  return pgdir;
80107415:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107418:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010741b:	c9                   	leave
8010741c:	c3                   	ret

8010741d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010741d:	55                   	push   %ebp
8010741e:	89 e5                	mov    %esp,%ebp
80107420:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107423:	e8 08 ff ff ff       	call   80107330 <setupkvm>
80107428:	a3 7c 6a 19 80       	mov    %eax,0x80196a7c
  switchkvm();
8010742d:	e8 03 00 00 00       	call   80107435 <switchkvm>
}
80107432:	90                   	nop
80107433:	c9                   	leave
80107434:	c3                   	ret

80107435 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107435:	55                   	push   %ebp
80107436:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107438:	a1 7c 6a 19 80       	mov    0x80196a7c,%eax
8010743d:	05 00 00 00 80       	add    $0x80000000,%eax
80107442:	50                   	push   %eax
80107443:	e8 60 fa ff ff       	call   80106ea8 <lcr3>
80107448:	83 c4 04             	add    $0x4,%esp
}
8010744b:	90                   	nop
8010744c:	c9                   	leave
8010744d:	c3                   	ret

8010744e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010744e:	55                   	push   %ebp
8010744f:	89 e5                	mov    %esp,%ebp
80107451:	56                   	push   %esi
80107452:	53                   	push   %ebx
80107453:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107456:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010745a:	75 0d                	jne    80107469 <switchuvm+0x1b>
    panic("switchuvm: no process");
8010745c:	83 ec 0c             	sub    $0xc,%esp
8010745f:	68 da a5 10 80       	push   $0x8010a5da
80107464:	e8 40 91 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
80107469:	8b 45 08             	mov    0x8(%ebp),%eax
8010746c:	8b 40 08             	mov    0x8(%eax),%eax
8010746f:	85 c0                	test   %eax,%eax
80107471:	75 0d                	jne    80107480 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107473:	83 ec 0c             	sub    $0xc,%esp
80107476:	68 f0 a5 10 80       	push   $0x8010a5f0
8010747b:	e8 29 91 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107480:	8b 45 08             	mov    0x8(%ebp),%eax
80107483:	8b 40 04             	mov    0x4(%eax),%eax
80107486:	85 c0                	test   %eax,%eax
80107488:	75 0d                	jne    80107497 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010748a:	83 ec 0c             	sub    $0xc,%esp
8010748d:	68 05 a6 10 80       	push   $0x8010a605
80107492:	e8 12 91 ff ff       	call   801005a9 <panic>

  pushcli();
80107497:	e8 f4 d3 ff ff       	call   80104890 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010749c:	e8 17 c5 ff ff       	call   801039b8 <mycpu>
801074a1:	89 c3                	mov    %eax,%ebx
801074a3:	e8 10 c5 ff ff       	call   801039b8 <mycpu>
801074a8:	83 c0 08             	add    $0x8,%eax
801074ab:	89 c6                	mov    %eax,%esi
801074ad:	e8 06 c5 ff ff       	call   801039b8 <mycpu>
801074b2:	83 c0 08             	add    $0x8,%eax
801074b5:	c1 e8 10             	shr    $0x10,%eax
801074b8:	88 45 f7             	mov    %al,-0x9(%ebp)
801074bb:	e8 f8 c4 ff ff       	call   801039b8 <mycpu>
801074c0:	83 c0 08             	add    $0x8,%eax
801074c3:	c1 e8 18             	shr    $0x18,%eax
801074c6:	89 c2                	mov    %eax,%edx
801074c8:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801074cf:	67 00 
801074d1:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801074d8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801074dc:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801074e2:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074e9:	83 e0 f0             	and    $0xfffffff0,%eax
801074ec:	83 c8 09             	or     $0x9,%eax
801074ef:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074f5:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074fc:	83 c8 10             	or     $0x10,%eax
801074ff:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107505:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010750c:	83 e0 9f             	and    $0xffffff9f,%eax
8010750f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107515:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010751c:	83 c8 80             	or     $0xffffff80,%eax
8010751f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107525:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010752c:	83 e0 f0             	and    $0xfffffff0,%eax
8010752f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107535:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010753c:	83 e0 ef             	and    $0xffffffef,%eax
8010753f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107545:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010754c:	83 e0 df             	and    $0xffffffdf,%eax
8010754f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107555:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010755c:	83 c8 40             	or     $0x40,%eax
8010755f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107565:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010756c:	83 e0 7f             	and    $0x7f,%eax
8010756f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107575:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010757b:	e8 38 c4 ff ff       	call   801039b8 <mycpu>
80107580:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107587:	83 e2 ef             	and    $0xffffffef,%edx
8010758a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107590:	e8 23 c4 ff ff       	call   801039b8 <mycpu>
80107595:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010759b:	8b 45 08             	mov    0x8(%ebp),%eax
8010759e:	8b 40 08             	mov    0x8(%eax),%eax
801075a1:	89 c3                	mov    %eax,%ebx
801075a3:	e8 10 c4 ff ff       	call   801039b8 <mycpu>
801075a8:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801075ae:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801075b1:	e8 02 c4 ff ff       	call   801039b8 <mycpu>
801075b6:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801075bc:	83 ec 0c             	sub    $0xc,%esp
801075bf:	6a 28                	push   $0x28
801075c1:	e8 cb f8 ff ff       	call   80106e91 <ltr>
801075c6:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801075c9:	8b 45 08             	mov    0x8(%ebp),%eax
801075cc:	8b 40 04             	mov    0x4(%eax),%eax
801075cf:	05 00 00 00 80       	add    $0x80000000,%eax
801075d4:	83 ec 0c             	sub    $0xc,%esp
801075d7:	50                   	push   %eax
801075d8:	e8 cb f8 ff ff       	call   80106ea8 <lcr3>
801075dd:	83 c4 10             	add    $0x10,%esp
  popcli();
801075e0:	e8 f8 d2 ff ff       	call   801048dd <popcli>
}
801075e5:	90                   	nop
801075e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801075e9:	5b                   	pop    %ebx
801075ea:	5e                   	pop    %esi
801075eb:	5d                   	pop    %ebp
801075ec:	c3                   	ret

801075ed <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801075ed:	55                   	push   %ebp
801075ee:	89 e5                	mov    %esp,%ebp
801075f0:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801075f3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801075fa:	76 0d                	jbe    80107609 <inituvm+0x1c>
    panic("inituvm: more than a page");
801075fc:	83 ec 0c             	sub    $0xc,%esp
801075ff:	68 19 a6 10 80       	push   $0x8010a619
80107604:	e8 a0 8f ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107609:	e8 9a b1 ff ff       	call   801027a8 <kalloc>
8010760e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107611:	83 ec 04             	sub    $0x4,%esp
80107614:	68 00 10 00 00       	push   $0x1000
80107619:	6a 00                	push   $0x0
8010761b:	ff 75 f4             	push   -0xc(%ebp)
8010761e:	e8 78 d3 ff ff       	call   8010499b <memset>
80107623:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107629:	05 00 00 00 80       	add    $0x80000000,%eax
8010762e:	83 ec 0c             	sub    $0xc,%esp
80107631:	6a 06                	push   $0x6
80107633:	50                   	push   %eax
80107634:	68 00 10 00 00       	push   $0x1000
80107639:	6a 00                	push   $0x0
8010763b:	ff 75 08             	push   0x8(%ebp)
8010763e:	e8 5d fc ff ff       	call   801072a0 <mappages>
80107643:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107646:	83 ec 04             	sub    $0x4,%esp
80107649:	ff 75 10             	push   0x10(%ebp)
8010764c:	ff 75 0c             	push   0xc(%ebp)
8010764f:	ff 75 f4             	push   -0xc(%ebp)
80107652:	e8 03 d4 ff ff       	call   80104a5a <memmove>
80107657:	83 c4 10             	add    $0x10,%esp
}
8010765a:	90                   	nop
8010765b:	c9                   	leave
8010765c:	c3                   	ret

8010765d <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010765d:	55                   	push   %ebp
8010765e:	89 e5                	mov    %esp,%ebp
80107660:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107663:	8b 45 0c             	mov    0xc(%ebp),%eax
80107666:	25 ff 0f 00 00       	and    $0xfff,%eax
8010766b:	85 c0                	test   %eax,%eax
8010766d:	74 0d                	je     8010767c <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010766f:	83 ec 0c             	sub    $0xc,%esp
80107672:	68 34 a6 10 80       	push   $0x8010a634
80107677:	e8 2d 8f ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010767c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107683:	e9 8f 00 00 00       	jmp    80107717 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107688:	8b 55 0c             	mov    0xc(%ebp),%edx
8010768b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768e:	01 d0                	add    %edx,%eax
80107690:	83 ec 04             	sub    $0x4,%esp
80107693:	6a 00                	push   $0x0
80107695:	50                   	push   %eax
80107696:	ff 75 08             	push   0x8(%ebp)
80107699:	e8 6c fb ff ff       	call   8010720a <walkpgdir>
8010769e:	83 c4 10             	add    $0x10,%esp
801076a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801076a4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801076a8:	75 0d                	jne    801076b7 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
801076aa:	83 ec 0c             	sub    $0xc,%esp
801076ad:	68 57 a6 10 80       	push   $0x8010a657
801076b2:	e8 f2 8e ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801076b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801076ba:	8b 00                	mov    (%eax),%eax
801076bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801076c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801076c4:	8b 45 18             	mov    0x18(%ebp),%eax
801076c7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801076ca:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801076cf:	77 0b                	ja     801076dc <loaduvm+0x7f>
      n = sz - i;
801076d1:	8b 45 18             	mov    0x18(%ebp),%eax
801076d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801076d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801076da:	eb 07                	jmp    801076e3 <loaduvm+0x86>
    else
      n = PGSIZE;
801076dc:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801076e3:	8b 55 14             	mov    0x14(%ebp),%edx
801076e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e9:	01 d0                	add    %edx,%eax
801076eb:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076ee:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801076f4:	ff 75 f0             	push   -0x10(%ebp)
801076f7:	50                   	push   %eax
801076f8:	52                   	push   %edx
801076f9:	ff 75 10             	push   0x10(%ebp)
801076fc:	e8 dd a7 ff ff       	call   80101ede <readi>
80107701:	83 c4 10             	add    $0x10,%esp
80107704:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107707:	74 07                	je     80107710 <loaduvm+0xb3>
      return -1;
80107709:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010770e:	eb 18                	jmp    80107728 <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107710:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771a:	3b 45 18             	cmp    0x18(%ebp),%eax
8010771d:	0f 82 65 ff ff ff    	jb     80107688 <loaduvm+0x2b>
  }
  return 0;
80107723:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107728:	c9                   	leave
80107729:	c3                   	ret

8010772a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010772a:	55                   	push   %ebp
8010772b:	89 e5                	mov    %esp,%ebp
8010772d:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107730:	8b 45 10             	mov    0x10(%ebp),%eax
80107733:	85 c0                	test   %eax,%eax
80107735:	79 0a                	jns    80107741 <allocuvm+0x17>
    return 0;
80107737:	b8 00 00 00 00       	mov    $0x0,%eax
8010773c:	e9 ec 00 00 00       	jmp    8010782d <allocuvm+0x103>
  if(newsz < oldsz)
80107741:	8b 45 10             	mov    0x10(%ebp),%eax
80107744:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107747:	73 08                	jae    80107751 <allocuvm+0x27>
    return oldsz;
80107749:	8b 45 0c             	mov    0xc(%ebp),%eax
8010774c:	e9 dc 00 00 00       	jmp    8010782d <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107751:	8b 45 0c             	mov    0xc(%ebp),%eax
80107754:	05 ff 0f 00 00       	add    $0xfff,%eax
80107759:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010775e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107761:	e9 b8 00 00 00       	jmp    8010781e <allocuvm+0xf4>
    mem = kalloc();
80107766:	e8 3d b0 ff ff       	call   801027a8 <kalloc>
8010776b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010776e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107772:	75 2e                	jne    801077a2 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107774:	83 ec 0c             	sub    $0xc,%esp
80107777:	68 75 a6 10 80       	push   $0x8010a675
8010777c:	e8 73 8c ff ff       	call   801003f4 <cprintf>
80107781:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107784:	83 ec 04             	sub    $0x4,%esp
80107787:	ff 75 0c             	push   0xc(%ebp)
8010778a:	ff 75 10             	push   0x10(%ebp)
8010778d:	ff 75 08             	push   0x8(%ebp)
80107790:	e8 9a 00 00 00       	call   8010782f <deallocuvm>
80107795:	83 c4 10             	add    $0x10,%esp
      return 0;
80107798:	b8 00 00 00 00       	mov    $0x0,%eax
8010779d:	e9 8b 00 00 00       	jmp    8010782d <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
801077a2:	83 ec 04             	sub    $0x4,%esp
801077a5:	68 00 10 00 00       	push   $0x1000
801077aa:	6a 00                	push   $0x0
801077ac:	ff 75 f0             	push   -0x10(%ebp)
801077af:	e8 e7 d1 ff ff       	call   8010499b <memset>
801077b4:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801077b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077ba:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801077c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c3:	83 ec 0c             	sub    $0xc,%esp
801077c6:	6a 06                	push   $0x6
801077c8:	52                   	push   %edx
801077c9:	68 00 10 00 00       	push   $0x1000
801077ce:	50                   	push   %eax
801077cf:	ff 75 08             	push   0x8(%ebp)
801077d2:	e8 c9 fa ff ff       	call   801072a0 <mappages>
801077d7:	83 c4 20             	add    $0x20,%esp
801077da:	85 c0                	test   %eax,%eax
801077dc:	79 39                	jns    80107817 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801077de:	83 ec 0c             	sub    $0xc,%esp
801077e1:	68 8d a6 10 80       	push   $0x8010a68d
801077e6:	e8 09 8c ff ff       	call   801003f4 <cprintf>
801077eb:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801077ee:	83 ec 04             	sub    $0x4,%esp
801077f1:	ff 75 0c             	push   0xc(%ebp)
801077f4:	ff 75 10             	push   0x10(%ebp)
801077f7:	ff 75 08             	push   0x8(%ebp)
801077fa:	e8 30 00 00 00       	call   8010782f <deallocuvm>
801077ff:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107802:	83 ec 0c             	sub    $0xc,%esp
80107805:	ff 75 f0             	push   -0x10(%ebp)
80107808:	e8 01 af ff ff       	call   8010270e <kfree>
8010780d:	83 c4 10             	add    $0x10,%esp
      return 0;
80107810:	b8 00 00 00 00       	mov    $0x0,%eax
80107815:	eb 16                	jmp    8010782d <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107817:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010781e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107821:	3b 45 10             	cmp    0x10(%ebp),%eax
80107824:	0f 82 3c ff ff ff    	jb     80107766 <allocuvm+0x3c>
    }
  }
  return newsz;
8010782a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010782d:	c9                   	leave
8010782e:	c3                   	ret

8010782f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010782f:	55                   	push   %ebp
80107830:	89 e5                	mov    %esp,%ebp
80107832:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107835:	8b 45 10             	mov    0x10(%ebp),%eax
80107838:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010783b:	72 08                	jb     80107845 <deallocuvm+0x16>
    return oldsz;
8010783d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107840:	e9 ac 00 00 00       	jmp    801078f1 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107845:	8b 45 10             	mov    0x10(%ebp),%eax
80107848:	05 ff 0f 00 00       	add    $0xfff,%eax
8010784d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107852:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107855:	e9 88 00 00 00       	jmp    801078e2 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010785a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785d:	83 ec 04             	sub    $0x4,%esp
80107860:	6a 00                	push   $0x0
80107862:	50                   	push   %eax
80107863:	ff 75 08             	push   0x8(%ebp)
80107866:	e8 9f f9 ff ff       	call   8010720a <walkpgdir>
8010786b:	83 c4 10             	add    $0x10,%esp
8010786e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107871:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107875:	75 16                	jne    8010788d <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787a:	c1 e8 16             	shr    $0x16,%eax
8010787d:	83 c0 01             	add    $0x1,%eax
80107880:	c1 e0 16             	shl    $0x16,%eax
80107883:	2d 00 10 00 00       	sub    $0x1000,%eax
80107888:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010788b:	eb 4e                	jmp    801078db <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010788d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107890:	8b 00                	mov    (%eax),%eax
80107892:	83 e0 01             	and    $0x1,%eax
80107895:	85 c0                	test   %eax,%eax
80107897:	74 42                	je     801078db <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010789c:	8b 00                	mov    (%eax),%eax
8010789e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801078a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078aa:	75 0d                	jne    801078b9 <deallocuvm+0x8a>
        panic("kfree");
801078ac:	83 ec 0c             	sub    $0xc,%esp
801078af:	68 a9 a6 10 80       	push   $0x8010a6a9
801078b4:	e8 f0 8c ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
801078b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078bc:	05 00 00 00 80       	add    $0x80000000,%eax
801078c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801078c4:	83 ec 0c             	sub    $0xc,%esp
801078c7:	ff 75 e8             	push   -0x18(%ebp)
801078ca:	e8 3f ae ff ff       	call   8010270e <kfree>
801078cf:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801078d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801078db:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
801078e8:	0f 82 6c ff ff ff    	jb     8010785a <deallocuvm+0x2b>
    }
  }
  return newsz;
801078ee:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078f1:	c9                   	leave
801078f2:	c3                   	ret

801078f3 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801078f3:	55                   	push   %ebp
801078f4:	89 e5                	mov    %esp,%ebp
801078f6:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801078f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801078fd:	75 0d                	jne    8010790c <freevm+0x19>
    panic("freevm: no pgdir");
801078ff:	83 ec 0c             	sub    $0xc,%esp
80107902:	68 af a6 10 80       	push   $0x8010a6af
80107907:	e8 9d 8c ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010790c:	83 ec 04             	sub    $0x4,%esp
8010790f:	6a 00                	push   $0x0
80107911:	68 00 00 00 80       	push   $0x80000000
80107916:	ff 75 08             	push   0x8(%ebp)
80107919:	e8 11 ff ff ff       	call   8010782f <deallocuvm>
8010791e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107921:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107928:	eb 48                	jmp    80107972 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
8010792a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107934:	8b 45 08             	mov    0x8(%ebp),%eax
80107937:	01 d0                	add    %edx,%eax
80107939:	8b 00                	mov    (%eax),%eax
8010793b:	83 e0 01             	and    $0x1,%eax
8010793e:	85 c0                	test   %eax,%eax
80107940:	74 2c                	je     8010796e <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107945:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010794c:	8b 45 08             	mov    0x8(%ebp),%eax
8010794f:	01 d0                	add    %edx,%eax
80107951:	8b 00                	mov    (%eax),%eax
80107953:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107958:	05 00 00 00 80       	add    $0x80000000,%eax
8010795d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107960:	83 ec 0c             	sub    $0xc,%esp
80107963:	ff 75 f0             	push   -0x10(%ebp)
80107966:	e8 a3 ad ff ff       	call   8010270e <kfree>
8010796b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010796e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107972:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107979:	76 af                	jbe    8010792a <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010797b:	83 ec 0c             	sub    $0xc,%esp
8010797e:	ff 75 08             	push   0x8(%ebp)
80107981:	e8 88 ad ff ff       	call   8010270e <kfree>
80107986:	83 c4 10             	add    $0x10,%esp
}
80107989:	90                   	nop
8010798a:	c9                   	leave
8010798b:	c3                   	ret

8010798c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010798c:	55                   	push   %ebp
8010798d:	89 e5                	mov    %esp,%ebp
8010798f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107992:	83 ec 04             	sub    $0x4,%esp
80107995:	6a 00                	push   $0x0
80107997:	ff 75 0c             	push   0xc(%ebp)
8010799a:	ff 75 08             	push   0x8(%ebp)
8010799d:	e8 68 f8 ff ff       	call   8010720a <walkpgdir>
801079a2:	83 c4 10             	add    $0x10,%esp
801079a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801079a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079ac:	75 0d                	jne    801079bb <clearpteu+0x2f>
    panic("clearpteu");
801079ae:	83 ec 0c             	sub    $0xc,%esp
801079b1:	68 c0 a6 10 80       	push   $0x8010a6c0
801079b6:	e8 ee 8b ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
801079bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079be:	8b 00                	mov    (%eax),%eax
801079c0:	83 e0 fb             	and    $0xfffffffb,%eax
801079c3:	89 c2                	mov    %eax,%edx
801079c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c8:	89 10                	mov    %edx,(%eax)
}
801079ca:	90                   	nop
801079cb:	c9                   	leave
801079cc:	c3                   	ret

801079cd <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801079cd:	55                   	push   %ebp
801079ce:	89 e5                	mov    %esp,%ebp
801079d0:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801079d3:	e8 58 f9 ff ff       	call   80107330 <setupkvm>
801079d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079df:	75 0a                	jne    801079eb <copyuvm+0x1e>
    return 0;
801079e1:	b8 00 00 00 00       	mov    $0x0,%eax
801079e6:	e9 eb 00 00 00       	jmp    80107ad6 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801079eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079f2:	e9 b7 00 00 00       	jmp    80107aae <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801079f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fa:	83 ec 04             	sub    $0x4,%esp
801079fd:	6a 00                	push   $0x0
801079ff:	50                   	push   %eax
80107a00:	ff 75 08             	push   0x8(%ebp)
80107a03:	e8 02 f8 ff ff       	call   8010720a <walkpgdir>
80107a08:	83 c4 10             	add    $0x10,%esp
80107a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a0e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a12:	75 0d                	jne    80107a21 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107a14:	83 ec 0c             	sub    $0xc,%esp
80107a17:	68 ca a6 10 80       	push   $0x8010a6ca
80107a1c:	e8 88 8b ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107a21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a24:	8b 00                	mov    (%eax),%eax
80107a26:	83 e0 01             	and    $0x1,%eax
80107a29:	85 c0                	test   %eax,%eax
80107a2b:	75 0d                	jne    80107a3a <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107a2d:	83 ec 0c             	sub    $0xc,%esp
80107a30:	68 e4 a6 10 80       	push   $0x8010a6e4
80107a35:	e8 6f 8b ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a3d:	8b 00                	mov    (%eax),%eax
80107a3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a44:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a4a:	8b 00                	mov    (%eax),%eax
80107a4c:	25 ff 0f 00 00       	and    $0xfff,%eax
80107a51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107a54:	e8 4f ad ff ff       	call   801027a8 <kalloc>
80107a59:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a5c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107a60:	74 5d                	je     80107abf <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107a62:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a65:	05 00 00 00 80       	add    $0x80000000,%eax
80107a6a:	83 ec 04             	sub    $0x4,%esp
80107a6d:	68 00 10 00 00       	push   $0x1000
80107a72:	50                   	push   %eax
80107a73:	ff 75 e0             	push   -0x20(%ebp)
80107a76:	e8 df cf ff ff       	call   80104a5a <memmove>
80107a7b:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107a7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a84:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8d:	83 ec 0c             	sub    $0xc,%esp
80107a90:	52                   	push   %edx
80107a91:	51                   	push   %ecx
80107a92:	68 00 10 00 00       	push   $0x1000
80107a97:	50                   	push   %eax
80107a98:	ff 75 f0             	push   -0x10(%ebp)
80107a9b:	e8 00 f8 ff ff       	call   801072a0 <mappages>
80107aa0:	83 c4 20             	add    $0x20,%esp
80107aa3:	85 c0                	test   %eax,%eax
80107aa5:	78 1b                	js     80107ac2 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107aa7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ab4:	0f 82 3d ff ff ff    	jb     801079f7 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107abd:	eb 17                	jmp    80107ad6 <copyuvm+0x109>
      goto bad;
80107abf:	90                   	nop
80107ac0:	eb 01                	jmp    80107ac3 <copyuvm+0xf6>
      goto bad;
80107ac2:	90                   	nop

bad:
  freevm(d);
80107ac3:	83 ec 0c             	sub    $0xc,%esp
80107ac6:	ff 75 f0             	push   -0x10(%ebp)
80107ac9:	e8 25 fe ff ff       	call   801078f3 <freevm>
80107ace:	83 c4 10             	add    $0x10,%esp
  return 0;
80107ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ad6:	c9                   	leave
80107ad7:	c3                   	ret

80107ad8 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107ad8:	55                   	push   %ebp
80107ad9:	89 e5                	mov    %esp,%ebp
80107adb:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107ade:	83 ec 04             	sub    $0x4,%esp
80107ae1:	6a 00                	push   $0x0
80107ae3:	ff 75 0c             	push   0xc(%ebp)
80107ae6:	ff 75 08             	push   0x8(%ebp)
80107ae9:	e8 1c f7 ff ff       	call   8010720a <walkpgdir>
80107aee:	83 c4 10             	add    $0x10,%esp
80107af1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af7:	8b 00                	mov    (%eax),%eax
80107af9:	83 e0 01             	and    $0x1,%eax
80107afc:	85 c0                	test   %eax,%eax
80107afe:	75 07                	jne    80107b07 <uva2ka+0x2f>
    return 0;
80107b00:	b8 00 00 00 00       	mov    $0x0,%eax
80107b05:	eb 22                	jmp    80107b29 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0a:	8b 00                	mov    (%eax),%eax
80107b0c:	83 e0 04             	and    $0x4,%eax
80107b0f:	85 c0                	test   %eax,%eax
80107b11:	75 07                	jne    80107b1a <uva2ka+0x42>
    return 0;
80107b13:	b8 00 00 00 00       	mov    $0x0,%eax
80107b18:	eb 0f                	jmp    80107b29 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1d:	8b 00                	mov    (%eax),%eax
80107b1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b24:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107b29:	c9                   	leave
80107b2a:	c3                   	ret

80107b2b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107b2b:	55                   	push   %ebp
80107b2c:	89 e5                	mov    %esp,%ebp
80107b2e:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107b31:	8b 45 10             	mov    0x10(%ebp),%eax
80107b34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107b37:	eb 7f                	jmp    80107bb8 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107b39:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b41:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b47:	83 ec 08             	sub    $0x8,%esp
80107b4a:	50                   	push   %eax
80107b4b:	ff 75 08             	push   0x8(%ebp)
80107b4e:	e8 85 ff ff ff       	call   80107ad8 <uva2ka>
80107b53:	83 c4 10             	add    $0x10,%esp
80107b56:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107b59:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107b5d:	75 07                	jne    80107b66 <copyout+0x3b>
      return -1;
80107b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b64:	eb 61                	jmp    80107bc7 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107b66:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b69:	2b 45 0c             	sub    0xc(%ebp),%eax
80107b6c:	05 00 10 00 00       	add    $0x1000,%eax
80107b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b77:	39 45 14             	cmp    %eax,0x14(%ebp)
80107b7a:	73 06                	jae    80107b82 <copyout+0x57>
      n = len;
80107b7c:	8b 45 14             	mov    0x14(%ebp),%eax
80107b7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107b82:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b85:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107b88:	89 c2                	mov    %eax,%edx
80107b8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b8d:	01 d0                	add    %edx,%eax
80107b8f:	83 ec 04             	sub    $0x4,%esp
80107b92:	ff 75 f0             	push   -0x10(%ebp)
80107b95:	ff 75 f4             	push   -0xc(%ebp)
80107b98:	50                   	push   %eax
80107b99:	e8 bc ce ff ff       	call   80104a5a <memmove>
80107b9e:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ba4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107baa:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107bad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bb0:	05 00 10 00 00       	add    $0x1000,%eax
80107bb5:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107bb8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107bbc:	0f 85 77 ff ff ff    	jne    80107b39 <copyout+0xe>
  }
  return 0;
80107bc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bc7:	c9                   	leave
80107bc8:	c3                   	ret

80107bc9 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107bc9:	55                   	push   %ebp
80107bca:	89 e5                	mov    %esp,%ebp
80107bcc:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107bcf:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107bd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107bd9:	8b 40 08             	mov    0x8(%eax),%eax
80107bdc:	05 00 00 00 80       	add    $0x80000000,%eax
80107be1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107be4:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bee:	8b 40 24             	mov    0x24(%eax),%eax
80107bf1:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107bf6:	c7 05 40 6d 19 80 00 	movl   $0x0,0x80196d40
80107bfd:	00 00 00 

  while(i<madt->len){
80107c00:	e9 bd 00 00 00       	jmp    80107cc2 <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
80107c05:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107c0b:	01 d0                	add    %edx,%eax
80107c0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c13:	0f b6 00             	movzbl (%eax),%eax
80107c16:	0f b6 c0             	movzbl %al,%eax
80107c19:	83 f8 05             	cmp    $0x5,%eax
80107c1c:	0f 87 a0 00 00 00    	ja     80107cc2 <mpinit_uefi+0xf9>
80107c22:	8b 04 85 00 a7 10 80 	mov    -0x7fef5900(,%eax,4),%eax
80107c29:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107c31:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107c36:	83 f8 03             	cmp    $0x3,%eax
80107c39:	7f 28                	jg     80107c63 <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107c3b:	8b 15 40 6d 19 80    	mov    0x80196d40,%edx
80107c41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c44:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107c48:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107c4e:	81 c2 80 6a 19 80    	add    $0x80196a80,%edx
80107c54:	88 02                	mov    %al,(%edx)
          ncpu++;
80107c56:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107c5b:	83 c0 01             	add    $0x1,%eax
80107c5e:	a3 40 6d 19 80       	mov    %eax,0x80196d40
        }
        i += lapic_entry->record_len;
80107c63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c66:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c6a:	0f b6 c0             	movzbl %al,%eax
80107c6d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c70:	eb 50                	jmp    80107cc2 <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107c78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c7b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107c7f:	a2 44 6d 19 80       	mov    %al,0x80196d44
        i += ioapic->record_len;
80107c84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c87:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c8b:	0f b6 c0             	movzbl %al,%eax
80107c8e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c91:	eb 2f                	jmp    80107cc2 <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107c93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c96:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107c99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c9c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107ca0:	0f b6 c0             	movzbl %al,%eax
80107ca3:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107ca6:	eb 1a                	jmp    80107cc2 <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cab:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107cae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107cb1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107cb5:	0f b6 c0             	movzbl %al,%eax
80107cb8:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107cbb:	eb 05                	jmp    80107cc2 <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
80107cbd:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107cc1:	90                   	nop
  while(i<madt->len){
80107cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc5:	8b 40 04             	mov    0x4(%eax),%eax
80107cc8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107ccb:	0f 82 34 ff ff ff    	jb     80107c05 <mpinit_uefi+0x3c>
    }
  }

}
80107cd1:	90                   	nop
80107cd2:	90                   	nop
80107cd3:	c9                   	leave
80107cd4:	c3                   	ret

80107cd5 <inb>:
{
80107cd5:	55                   	push   %ebp
80107cd6:	89 e5                	mov    %esp,%ebp
80107cd8:	83 ec 14             	sub    $0x14,%esp
80107cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80107cde:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107ce2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107ce6:	89 c2                	mov    %eax,%edx
80107ce8:	ec                   	in     (%dx),%al
80107ce9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107cec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107cf0:	c9                   	leave
80107cf1:	c3                   	ret

80107cf2 <outb>:
{
80107cf2:	55                   	push   %ebp
80107cf3:	89 e5                	mov    %esp,%ebp
80107cf5:	83 ec 08             	sub    $0x8,%esp
80107cf8:	8b 55 08             	mov    0x8(%ebp),%edx
80107cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cfe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107d02:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107d05:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107d09:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107d0d:	ee                   	out    %al,(%dx)
}
80107d0e:	90                   	nop
80107d0f:	c9                   	leave
80107d10:	c3                   	ret

80107d11 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107d11:	55                   	push   %ebp
80107d12:	89 e5                	mov    %esp,%ebp
80107d14:	83 ec 28             	sub    $0x28,%esp
80107d17:	8b 45 08             	mov    0x8(%ebp),%eax
80107d1a:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107d1d:	6a 00                	push   $0x0
80107d1f:	68 fa 03 00 00       	push   $0x3fa
80107d24:	e8 c9 ff ff ff       	call   80107cf2 <outb>
80107d29:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107d2c:	68 80 00 00 00       	push   $0x80
80107d31:	68 fb 03 00 00       	push   $0x3fb
80107d36:	e8 b7 ff ff ff       	call   80107cf2 <outb>
80107d3b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107d3e:	6a 0c                	push   $0xc
80107d40:	68 f8 03 00 00       	push   $0x3f8
80107d45:	e8 a8 ff ff ff       	call   80107cf2 <outb>
80107d4a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107d4d:	6a 00                	push   $0x0
80107d4f:	68 f9 03 00 00       	push   $0x3f9
80107d54:	e8 99 ff ff ff       	call   80107cf2 <outb>
80107d59:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107d5c:	6a 03                	push   $0x3
80107d5e:	68 fb 03 00 00       	push   $0x3fb
80107d63:	e8 8a ff ff ff       	call   80107cf2 <outb>
80107d68:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107d6b:	6a 00                	push   $0x0
80107d6d:	68 fc 03 00 00       	push   $0x3fc
80107d72:	e8 7b ff ff ff       	call   80107cf2 <outb>
80107d77:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107d7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d81:	eb 11                	jmp    80107d94 <uart_debug+0x83>
80107d83:	83 ec 0c             	sub    $0xc,%esp
80107d86:	6a 0a                	push   $0xa
80107d88:	e8 ac ad ff ff       	call   80102b39 <microdelay>
80107d8d:	83 c4 10             	add    $0x10,%esp
80107d90:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107d94:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107d98:	7f 1a                	jg     80107db4 <uart_debug+0xa3>
80107d9a:	83 ec 0c             	sub    $0xc,%esp
80107d9d:	68 fd 03 00 00       	push   $0x3fd
80107da2:	e8 2e ff ff ff       	call   80107cd5 <inb>
80107da7:	83 c4 10             	add    $0x10,%esp
80107daa:	0f b6 c0             	movzbl %al,%eax
80107dad:	83 e0 20             	and    $0x20,%eax
80107db0:	85 c0                	test   %eax,%eax
80107db2:	74 cf                	je     80107d83 <uart_debug+0x72>
  outb(COM1+0, p);
80107db4:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107db8:	0f b6 c0             	movzbl %al,%eax
80107dbb:	83 ec 08             	sub    $0x8,%esp
80107dbe:	50                   	push   %eax
80107dbf:	68 f8 03 00 00       	push   $0x3f8
80107dc4:	e8 29 ff ff ff       	call   80107cf2 <outb>
80107dc9:	83 c4 10             	add    $0x10,%esp
}
80107dcc:	90                   	nop
80107dcd:	c9                   	leave
80107dce:	c3                   	ret

80107dcf <uart_debugs>:

void uart_debugs(char *p){
80107dcf:	55                   	push   %ebp
80107dd0:	89 e5                	mov    %esp,%ebp
80107dd2:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107dd5:	eb 1b                	jmp    80107df2 <uart_debugs+0x23>
    uart_debug(*p++);
80107dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dda:	8d 50 01             	lea    0x1(%eax),%edx
80107ddd:	89 55 08             	mov    %edx,0x8(%ebp)
80107de0:	0f b6 00             	movzbl (%eax),%eax
80107de3:	0f be c0             	movsbl %al,%eax
80107de6:	83 ec 0c             	sub    $0xc,%esp
80107de9:	50                   	push   %eax
80107dea:	e8 22 ff ff ff       	call   80107d11 <uart_debug>
80107def:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107df2:	8b 45 08             	mov    0x8(%ebp),%eax
80107df5:	0f b6 00             	movzbl (%eax),%eax
80107df8:	84 c0                	test   %al,%al
80107dfa:	75 db                	jne    80107dd7 <uart_debugs+0x8>
  }
}
80107dfc:	90                   	nop
80107dfd:	90                   	nop
80107dfe:	c9                   	leave
80107dff:	c3                   	ret

80107e00 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107e00:	55                   	push   %ebp
80107e01:	89 e5                	mov    %esp,%ebp
80107e03:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107e06:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107e0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e10:	8b 50 14             	mov    0x14(%eax),%edx
80107e13:	8b 40 10             	mov    0x10(%eax),%eax
80107e16:	a3 48 6d 19 80       	mov    %eax,0x80196d48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107e1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e1e:	8b 50 1c             	mov    0x1c(%eax),%edx
80107e21:	8b 40 18             	mov    0x18(%eax),%eax
80107e24:	a3 50 6d 19 80       	mov    %eax,0x80196d50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107e29:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107e2e:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107e33:	29 c2                	sub    %eax,%edx
80107e35:	89 15 4c 6d 19 80    	mov    %edx,0x80196d4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107e3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e3e:	8b 50 24             	mov    0x24(%eax),%edx
80107e41:	8b 40 20             	mov    0x20(%eax),%eax
80107e44:	a3 54 6d 19 80       	mov    %eax,0x80196d54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107e49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e4c:	8b 50 2c             	mov    0x2c(%eax),%edx
80107e4f:	8b 40 28             	mov    0x28(%eax),%eax
80107e52:	a3 58 6d 19 80       	mov    %eax,0x80196d58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e5a:	8b 50 34             	mov    0x34(%eax),%edx
80107e5d:	8b 40 30             	mov    0x30(%eax),%eax
80107e60:	a3 5c 6d 19 80       	mov    %eax,0x80196d5c
}
80107e65:	90                   	nop
80107e66:	c9                   	leave
80107e67:	c3                   	ret

80107e68 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107e68:	55                   	push   %ebp
80107e69:	89 e5                	mov    %esp,%ebp
80107e6b:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107e6e:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80107e74:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e77:	0f af d0             	imul   %eax,%edx
80107e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80107e7d:	01 d0                	add    %edx,%eax
80107e7f:	c1 e0 02             	shl    $0x2,%eax
80107e82:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107e85:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
80107e8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e8e:	01 d0                	add    %edx,%eax
80107e90:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107e93:	8b 45 10             	mov    0x10(%ebp),%eax
80107e96:	0f b6 10             	movzbl (%eax),%edx
80107e99:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e9c:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107e9e:	8b 45 10             	mov    0x10(%ebp),%eax
80107ea1:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107ea5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107ea8:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107eab:	8b 45 10             	mov    0x10(%ebp),%eax
80107eae:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107eb2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107eb5:	88 50 02             	mov    %dl,0x2(%eax)
}
80107eb8:	90                   	nop
80107eb9:	c9                   	leave
80107eba:	c3                   	ret

80107ebb <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107ebb:	55                   	push   %ebp
80107ebc:	89 e5                	mov    %esp,%ebp
80107ebe:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107ec1:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80107ec7:	8b 45 08             	mov    0x8(%ebp),%eax
80107eca:	0f af c2             	imul   %edx,%eax
80107ecd:	c1 e0 02             	shl    $0x2,%eax
80107ed0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107ed3:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edc:	29 c2                	sub    %eax,%edx
80107ede:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
80107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee7:	01 c8                	add    %ecx,%eax
80107ee9:	89 c1                	mov    %eax,%ecx
80107eeb:	a1 4c 6d 19 80       	mov    0x80196d4c,%eax
80107ef0:	83 ec 04             	sub    $0x4,%esp
80107ef3:	52                   	push   %edx
80107ef4:	51                   	push   %ecx
80107ef5:	50                   	push   %eax
80107ef6:	e8 5f cb ff ff       	call   80104a5a <memmove>
80107efb:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f01:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
80107f07:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107f0d:	01 d1                	add    %edx,%ecx
80107f0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107f12:	29 d1                	sub    %edx,%ecx
80107f14:	89 ca                	mov    %ecx,%edx
80107f16:	83 ec 04             	sub    $0x4,%esp
80107f19:	50                   	push   %eax
80107f1a:	6a 00                	push   $0x0
80107f1c:	52                   	push   %edx
80107f1d:	e8 79 ca ff ff       	call   8010499b <memset>
80107f22:	83 c4 10             	add    $0x10,%esp
}
80107f25:	90                   	nop
80107f26:	c9                   	leave
80107f27:	c3                   	ret

80107f28 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107f28:	55                   	push   %ebp
80107f29:	89 e5                	mov    %esp,%ebp
80107f2b:	53                   	push   %ebx
80107f2c:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107f2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f36:	e9 b1 00 00 00       	jmp    80107fec <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107f3b:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107f42:	e9 97 00 00 00       	jmp    80107fde <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107f47:	8b 45 10             	mov    0x10(%ebp),%eax
80107f4a:	83 e8 20             	sub    $0x20,%eax
80107f4d:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f53:	01 d0                	add    %edx,%eax
80107f55:	0f b7 84 00 20 a7 10 	movzwl -0x7fef58e0(%eax,%eax,1),%eax
80107f5c:	80 
80107f5d:	0f b7 d0             	movzwl %ax,%edx
80107f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f63:	bb 01 00 00 00       	mov    $0x1,%ebx
80107f68:	89 c1                	mov    %eax,%ecx
80107f6a:	d3 e3                	shl    %cl,%ebx
80107f6c:	89 d8                	mov    %ebx,%eax
80107f6e:	21 d0                	and    %edx,%eax
80107f70:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80107f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f76:	ba 01 00 00 00       	mov    $0x1,%edx
80107f7b:	89 c1                	mov    %eax,%ecx
80107f7d:	d3 e2                	shl    %cl,%edx
80107f7f:	89 d0                	mov    %edx,%eax
80107f81:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80107f84:	75 2b                	jne    80107fb1 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80107f86:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8c:	01 c2                	add    %eax,%edx
80107f8e:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f93:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f96:	89 c1                	mov    %eax,%ecx
80107f98:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9b:	01 c8                	add    %ecx,%eax
80107f9d:	83 ec 04             	sub    $0x4,%esp
80107fa0:	68 e0 f4 10 80       	push   $0x8010f4e0
80107fa5:	52                   	push   %edx
80107fa6:	50                   	push   %eax
80107fa7:	e8 bc fe ff ff       	call   80107e68 <graphic_draw_pixel>
80107fac:	83 c4 10             	add    $0x10,%esp
80107faf:	eb 29                	jmp    80107fda <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80107fb1:	8b 55 0c             	mov    0xc(%ebp),%edx
80107fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb7:	01 c2                	add    %eax,%edx
80107fb9:	b8 0e 00 00 00       	mov    $0xe,%eax
80107fbe:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107fc1:	89 c1                	mov    %eax,%ecx
80107fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc6:	01 c8                	add    %ecx,%eax
80107fc8:	83 ec 04             	sub    $0x4,%esp
80107fcb:	68 60 6d 19 80       	push   $0x80196d60
80107fd0:	52                   	push   %edx
80107fd1:	50                   	push   %eax
80107fd2:	e8 91 fe ff ff       	call   80107e68 <graphic_draw_pixel>
80107fd7:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80107fda:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80107fde:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fe2:	0f 89 5f ff ff ff    	jns    80107f47 <font_render+0x1f>
  for(int i=0;i<30;i++){
80107fe8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fec:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80107ff0:	0f 8e 45 ff ff ff    	jle    80107f3b <font_render+0x13>
      }
    }
  }
}
80107ff6:	90                   	nop
80107ff7:	90                   	nop
80107ff8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107ffb:	c9                   	leave
80107ffc:	c3                   	ret

80107ffd <font_render_string>:

void font_render_string(char *string,int row){
80107ffd:	55                   	push   %ebp
80107ffe:	89 e5                	mov    %esp,%ebp
80108000:	53                   	push   %ebx
80108001:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80108004:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
8010800b:	eb 33                	jmp    80108040 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
8010800d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108010:	8b 45 08             	mov    0x8(%ebp),%eax
80108013:	01 d0                	add    %edx,%eax
80108015:	0f b6 00             	movzbl (%eax),%eax
80108018:	0f be d8             	movsbl %al,%ebx
8010801b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010801e:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108021:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108024:	89 d0                	mov    %edx,%eax
80108026:	c1 e0 04             	shl    $0x4,%eax
80108029:	29 d0                	sub    %edx,%eax
8010802b:	83 c0 02             	add    $0x2,%eax
8010802e:	83 ec 04             	sub    $0x4,%esp
80108031:	53                   	push   %ebx
80108032:	51                   	push   %ecx
80108033:	50                   	push   %eax
80108034:	e8 ef fe ff ff       	call   80107f28 <font_render>
80108039:	83 c4 10             	add    $0x10,%esp
    i++;
8010803c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108040:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108043:	8b 45 08             	mov    0x8(%ebp),%eax
80108046:	01 d0                	add    %edx,%eax
80108048:	0f b6 00             	movzbl (%eax),%eax
8010804b:	84 c0                	test   %al,%al
8010804d:	74 06                	je     80108055 <font_render_string+0x58>
8010804f:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108053:	7e b8                	jle    8010800d <font_render_string+0x10>
  }
}
80108055:	90                   	nop
80108056:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108059:	c9                   	leave
8010805a:	c3                   	ret

8010805b <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010805b:	55                   	push   %ebp
8010805c:	89 e5                	mov    %esp,%ebp
8010805e:	53                   	push   %ebx
8010805f:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108062:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108069:	eb 6b                	jmp    801080d6 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010806b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108072:	eb 58                	jmp    801080cc <pci_init+0x71>
      for(int k=0;k<8;k++){
80108074:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010807b:	eb 45                	jmp    801080c2 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010807d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108080:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108086:	83 ec 0c             	sub    $0xc,%esp
80108089:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010808c:	53                   	push   %ebx
8010808d:	6a 00                	push   $0x0
8010808f:	51                   	push   %ecx
80108090:	52                   	push   %edx
80108091:	50                   	push   %eax
80108092:	e8 b0 00 00 00       	call   80108147 <pci_access_config>
80108097:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010809a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010809d:	0f b7 c0             	movzwl %ax,%eax
801080a0:	3d ff ff 00 00       	cmp    $0xffff,%eax
801080a5:	74 17                	je     801080be <pci_init+0x63>
        pci_init_device(i,j,k);
801080a7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801080aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801080ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b0:	83 ec 04             	sub    $0x4,%esp
801080b3:	51                   	push   %ecx
801080b4:	52                   	push   %edx
801080b5:	50                   	push   %eax
801080b6:	e8 37 01 00 00       	call   801081f2 <pci_init_device>
801080bb:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801080be:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801080c2:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801080c6:	7e b5                	jle    8010807d <pci_init+0x22>
    for(int j=0;j<32;j++){
801080c8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801080cc:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801080d0:	7e a2                	jle    80108074 <pci_init+0x19>
  for(int i=0;i<256;i++){
801080d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080d6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801080dd:	7e 8c                	jle    8010806b <pci_init+0x10>
      }
      }
    }
  }
}
801080df:	90                   	nop
801080e0:	90                   	nop
801080e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080e4:	c9                   	leave
801080e5:	c3                   	ret

801080e6 <pci_write_config>:

void pci_write_config(uint config){
801080e6:	55                   	push   %ebp
801080e7:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801080e9:	8b 45 08             	mov    0x8(%ebp),%eax
801080ec:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801080f1:	89 c0                	mov    %eax,%eax
801080f3:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801080f4:	90                   	nop
801080f5:	5d                   	pop    %ebp
801080f6:	c3                   	ret

801080f7 <pci_write_data>:

void pci_write_data(uint config){
801080f7:	55                   	push   %ebp
801080f8:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801080fa:	8b 45 08             	mov    0x8(%ebp),%eax
801080fd:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108102:	89 c0                	mov    %eax,%eax
80108104:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
80108105:	90                   	nop
80108106:	5d                   	pop    %ebp
80108107:	c3                   	ret

80108108 <pci_read_config>:
uint pci_read_config(){
80108108:	55                   	push   %ebp
80108109:	89 e5                	mov    %esp,%ebp
8010810b:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
8010810e:	ba fc 0c 00 00       	mov    $0xcfc,%edx
80108113:	ed                   	in     (%dx),%eax
80108114:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
80108117:	83 ec 0c             	sub    $0xc,%esp
8010811a:	68 c8 00 00 00       	push   $0xc8
8010811f:	e8 15 aa ff ff       	call   80102b39 <microdelay>
80108124:	83 c4 10             	add    $0x10,%esp
  return data;
80108127:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010812a:	c9                   	leave
8010812b:	c3                   	ret

8010812c <pci_test>:


void pci_test(){
8010812c:	55                   	push   %ebp
8010812d:	89 e5                	mov    %esp,%ebp
8010812f:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108132:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
80108139:	ff 75 fc             	push   -0x4(%ebp)
8010813c:	e8 a5 ff ff ff       	call   801080e6 <pci_write_config>
80108141:	83 c4 04             	add    $0x4,%esp
}
80108144:	90                   	nop
80108145:	c9                   	leave
80108146:	c3                   	ret

80108147 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108147:	55                   	push   %ebp
80108148:	89 e5                	mov    %esp,%ebp
8010814a:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010814d:	8b 45 08             	mov    0x8(%ebp),%eax
80108150:	c1 e0 10             	shl    $0x10,%eax
80108153:	25 00 00 ff 00       	and    $0xff0000,%eax
80108158:	89 c2                	mov    %eax,%edx
8010815a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010815d:	c1 e0 0b             	shl    $0xb,%eax
80108160:	0f b7 c0             	movzwl %ax,%eax
80108163:	09 c2                	or     %eax,%edx
80108165:	8b 45 10             	mov    0x10(%ebp),%eax
80108168:	c1 e0 08             	shl    $0x8,%eax
8010816b:	25 00 07 00 00       	and    $0x700,%eax
80108170:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108172:	8b 45 14             	mov    0x14(%ebp),%eax
80108175:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010817a:	09 d0                	or     %edx,%eax
8010817c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108181:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108184:	ff 75 f4             	push   -0xc(%ebp)
80108187:	e8 5a ff ff ff       	call   801080e6 <pci_write_config>
8010818c:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010818f:	e8 74 ff ff ff       	call   80108108 <pci_read_config>
80108194:	8b 55 18             	mov    0x18(%ebp),%edx
80108197:	89 02                	mov    %eax,(%edx)
}
80108199:	90                   	nop
8010819a:	c9                   	leave
8010819b:	c3                   	ret

8010819c <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010819c:	55                   	push   %ebp
8010819d:	89 e5                	mov    %esp,%ebp
8010819f:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801081a2:	8b 45 08             	mov    0x8(%ebp),%eax
801081a5:	c1 e0 10             	shl    $0x10,%eax
801081a8:	25 00 00 ff 00       	and    $0xff0000,%eax
801081ad:	89 c2                	mov    %eax,%edx
801081af:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b2:	c1 e0 0b             	shl    $0xb,%eax
801081b5:	0f b7 c0             	movzwl %ax,%eax
801081b8:	09 c2                	or     %eax,%edx
801081ba:	8b 45 10             	mov    0x10(%ebp),%eax
801081bd:	c1 e0 08             	shl    $0x8,%eax
801081c0:	25 00 07 00 00       	and    $0x700,%eax
801081c5:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801081c7:	8b 45 14             	mov    0x14(%ebp),%eax
801081ca:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801081cf:	09 d0                	or     %edx,%eax
801081d1:	0d 00 00 00 80       	or     $0x80000000,%eax
801081d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801081d9:	ff 75 fc             	push   -0x4(%ebp)
801081dc:	e8 05 ff ff ff       	call   801080e6 <pci_write_config>
801081e1:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801081e4:	ff 75 18             	push   0x18(%ebp)
801081e7:	e8 0b ff ff ff       	call   801080f7 <pci_write_data>
801081ec:	83 c4 04             	add    $0x4,%esp
}
801081ef:	90                   	nop
801081f0:	c9                   	leave
801081f1:	c3                   	ret

801081f2 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801081f2:	55                   	push   %ebp
801081f3:	89 e5                	mov    %esp,%ebp
801081f5:	53                   	push   %ebx
801081f6:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801081f9:	8b 45 08             	mov    0x8(%ebp),%eax
801081fc:	a2 64 6d 19 80       	mov    %al,0x80196d64
  dev.device_num = device_num;
80108201:	8b 45 0c             	mov    0xc(%ebp),%eax
80108204:	a2 65 6d 19 80       	mov    %al,0x80196d65
  dev.function_num = function_num;
80108209:	8b 45 10             	mov    0x10(%ebp),%eax
8010820c:	a2 66 6d 19 80       	mov    %al,0x80196d66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
80108211:	ff 75 10             	push   0x10(%ebp)
80108214:	ff 75 0c             	push   0xc(%ebp)
80108217:	ff 75 08             	push   0x8(%ebp)
8010821a:	68 64 bd 10 80       	push   $0x8010bd64
8010821f:	e8 d0 81 ff ff       	call   801003f4 <cprintf>
80108224:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108227:	83 ec 0c             	sub    $0xc,%esp
8010822a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010822d:	50                   	push   %eax
8010822e:	6a 00                	push   $0x0
80108230:	ff 75 10             	push   0x10(%ebp)
80108233:	ff 75 0c             	push   0xc(%ebp)
80108236:	ff 75 08             	push   0x8(%ebp)
80108239:	e8 09 ff ff ff       	call   80108147 <pci_access_config>
8010823e:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108241:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108244:	c1 e8 10             	shr    $0x10,%eax
80108247:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010824a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010824d:	25 ff ff 00 00       	and    $0xffff,%eax
80108252:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108258:	a3 68 6d 19 80       	mov    %eax,0x80196d68
  dev.vendor_id = vendor_id;
8010825d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108260:	a3 6c 6d 19 80       	mov    %eax,0x80196d6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108265:	83 ec 04             	sub    $0x4,%esp
80108268:	ff 75 f0             	push   -0x10(%ebp)
8010826b:	ff 75 f4             	push   -0xc(%ebp)
8010826e:	68 98 bd 10 80       	push   $0x8010bd98
80108273:	e8 7c 81 ff ff       	call   801003f4 <cprintf>
80108278:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010827b:	83 ec 0c             	sub    $0xc,%esp
8010827e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108281:	50                   	push   %eax
80108282:	6a 08                	push   $0x8
80108284:	ff 75 10             	push   0x10(%ebp)
80108287:	ff 75 0c             	push   0xc(%ebp)
8010828a:	ff 75 08             	push   0x8(%ebp)
8010828d:	e8 b5 fe ff ff       	call   80108147 <pci_access_config>
80108292:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108295:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108298:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010829b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010829e:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801082a1:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
801082a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082a7:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
801082aa:	0f b6 c0             	movzbl %al,%eax
801082ad:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801082b0:	c1 eb 18             	shr    $0x18,%ebx
801082b3:	83 ec 0c             	sub    $0xc,%esp
801082b6:	51                   	push   %ecx
801082b7:	52                   	push   %edx
801082b8:	50                   	push   %eax
801082b9:	53                   	push   %ebx
801082ba:	68 bc bd 10 80       	push   $0x8010bdbc
801082bf:	e8 30 81 ff ff       	call   801003f4 <cprintf>
801082c4:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801082c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ca:	c1 e8 18             	shr    $0x18,%eax
801082cd:	a2 70 6d 19 80       	mov    %al,0x80196d70
  dev.sub_class = (data>>16)&0xFF;
801082d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082d5:	c1 e8 10             	shr    $0x10,%eax
801082d8:	a2 71 6d 19 80       	mov    %al,0x80196d71
  dev.interface = (data>>8)&0xFF;
801082dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082e0:	c1 e8 08             	shr    $0x8,%eax
801082e3:	a2 72 6d 19 80       	mov    %al,0x80196d72
  dev.revision_id = data&0xFF;
801082e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082eb:	a2 73 6d 19 80       	mov    %al,0x80196d73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801082f0:	83 ec 0c             	sub    $0xc,%esp
801082f3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082f6:	50                   	push   %eax
801082f7:	6a 10                	push   $0x10
801082f9:	ff 75 10             	push   0x10(%ebp)
801082fc:	ff 75 0c             	push   0xc(%ebp)
801082ff:	ff 75 08             	push   0x8(%ebp)
80108302:	e8 40 fe ff ff       	call   80108147 <pci_access_config>
80108307:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
8010830a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010830d:	a3 74 6d 19 80       	mov    %eax,0x80196d74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
80108312:	83 ec 0c             	sub    $0xc,%esp
80108315:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108318:	50                   	push   %eax
80108319:	6a 14                	push   $0x14
8010831b:	ff 75 10             	push   0x10(%ebp)
8010831e:	ff 75 0c             	push   0xc(%ebp)
80108321:	ff 75 08             	push   0x8(%ebp)
80108324:	e8 1e fe ff ff       	call   80108147 <pci_access_config>
80108329:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010832c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010832f:	a3 78 6d 19 80       	mov    %eax,0x80196d78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108334:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010833b:	75 5a                	jne    80108397 <pci_init_device+0x1a5>
8010833d:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108344:	75 51                	jne    80108397 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108346:	83 ec 0c             	sub    $0xc,%esp
80108349:	68 01 be 10 80       	push   $0x8010be01
8010834e:	e8 a1 80 ff ff       	call   801003f4 <cprintf>
80108353:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108356:	83 ec 0c             	sub    $0xc,%esp
80108359:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010835c:	50                   	push   %eax
8010835d:	68 f0 00 00 00       	push   $0xf0
80108362:	ff 75 10             	push   0x10(%ebp)
80108365:	ff 75 0c             	push   0xc(%ebp)
80108368:	ff 75 08             	push   0x8(%ebp)
8010836b:	e8 d7 fd ff ff       	call   80108147 <pci_access_config>
80108370:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108376:	83 ec 08             	sub    $0x8,%esp
80108379:	50                   	push   %eax
8010837a:	68 1b be 10 80       	push   $0x8010be1b
8010837f:	e8 70 80 ff ff       	call   801003f4 <cprintf>
80108384:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108387:	83 ec 0c             	sub    $0xc,%esp
8010838a:	68 64 6d 19 80       	push   $0x80196d64
8010838f:	e8 09 00 00 00       	call   8010839d <i8254_init>
80108394:	83 c4 10             	add    $0x10,%esp
  }
}
80108397:	90                   	nop
80108398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010839b:	c9                   	leave
8010839c:	c3                   	ret

8010839d <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010839d:	55                   	push   %ebp
8010839e:	89 e5                	mov    %esp,%ebp
801083a0:	53                   	push   %ebx
801083a1:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
801083a4:	8b 45 08             	mov    0x8(%ebp),%eax
801083a7:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801083ab:	0f b6 c8             	movzbl %al,%ecx
801083ae:	8b 45 08             	mov    0x8(%ebp),%eax
801083b1:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083b5:	0f b6 d0             	movzbl %al,%edx
801083b8:	8b 45 08             	mov    0x8(%ebp),%eax
801083bb:	0f b6 00             	movzbl (%eax),%eax
801083be:	0f b6 c0             	movzbl %al,%eax
801083c1:	83 ec 0c             	sub    $0xc,%esp
801083c4:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801083c7:	53                   	push   %ebx
801083c8:	6a 04                	push   $0x4
801083ca:	51                   	push   %ecx
801083cb:	52                   	push   %edx
801083cc:	50                   	push   %eax
801083cd:	e8 75 fd ff ff       	call   80108147 <pci_access_config>
801083d2:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801083d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083d8:	83 c8 04             	or     $0x4,%eax
801083db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801083de:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801083e1:	8b 45 08             	mov    0x8(%ebp),%eax
801083e4:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801083e8:	0f b6 c8             	movzbl %al,%ecx
801083eb:	8b 45 08             	mov    0x8(%ebp),%eax
801083ee:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083f2:	0f b6 d0             	movzbl %al,%edx
801083f5:	8b 45 08             	mov    0x8(%ebp),%eax
801083f8:	0f b6 00             	movzbl (%eax),%eax
801083fb:	0f b6 c0             	movzbl %al,%eax
801083fe:	83 ec 0c             	sub    $0xc,%esp
80108401:	53                   	push   %ebx
80108402:	6a 04                	push   $0x4
80108404:	51                   	push   %ecx
80108405:	52                   	push   %edx
80108406:	50                   	push   %eax
80108407:	e8 90 fd ff ff       	call   8010819c <pci_write_config_register>
8010840c:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
8010840f:	8b 45 08             	mov    0x8(%ebp),%eax
80108412:	8b 40 10             	mov    0x10(%eax),%eax
80108415:	05 00 00 00 40       	add    $0x40000000,%eax
8010841a:	a3 7c 6d 19 80       	mov    %eax,0x80196d7c
  uint *ctrl = (uint *)base_addr;
8010841f:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108424:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108427:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010842c:	05 d8 00 00 00       	add    $0xd8,%eax
80108431:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108437:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
8010843d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108440:	8b 00                	mov    (%eax),%eax
80108442:	0d 00 00 00 04       	or     $0x4000000,%eax
80108447:	89 c2                	mov    %eax,%edx
80108449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844c:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
8010844e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108451:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845a:	8b 00                	mov    (%eax),%eax
8010845c:	83 c8 40             	or     $0x40,%eax
8010845f:	89 c2                	mov    %eax,%edx
80108461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108464:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108469:	8b 10                	mov    (%eax),%edx
8010846b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846e:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108470:	83 ec 0c             	sub    $0xc,%esp
80108473:	68 30 be 10 80       	push   $0x8010be30
80108478:	e8 77 7f ff ff       	call   801003f4 <cprintf>
8010847d:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108480:	e8 23 a3 ff ff       	call   801027a8 <kalloc>
80108485:	a3 88 6d 19 80       	mov    %eax,0x80196d88
  *intr_addr = 0;
8010848a:	a1 88 6d 19 80       	mov    0x80196d88,%eax
8010848f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108495:	a1 88 6d 19 80       	mov    0x80196d88,%eax
8010849a:	83 ec 08             	sub    $0x8,%esp
8010849d:	50                   	push   %eax
8010849e:	68 52 be 10 80       	push   $0x8010be52
801084a3:	e8 4c 7f ff ff       	call   801003f4 <cprintf>
801084a8:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
801084ab:	e8 50 00 00 00       	call   80108500 <i8254_init_recv>
  i8254_init_send();
801084b0:	e8 69 03 00 00       	call   8010881e <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
801084b5:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801084bc:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801084bf:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801084c6:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801084c9:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801084d0:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801084d3:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801084da:	0f b6 c0             	movzbl %al,%eax
801084dd:	83 ec 0c             	sub    $0xc,%esp
801084e0:	53                   	push   %ebx
801084e1:	51                   	push   %ecx
801084e2:	52                   	push   %edx
801084e3:	50                   	push   %eax
801084e4:	68 60 be 10 80       	push   $0x8010be60
801084e9:	e8 06 7f ff ff       	call   801003f4 <cprintf>
801084ee:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801084f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801084fa:	90                   	nop
801084fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084fe:	c9                   	leave
801084ff:	c3                   	ret

80108500 <i8254_init_recv>:

void i8254_init_recv(){
80108500:	55                   	push   %ebp
80108501:	89 e5                	mov    %esp,%ebp
80108503:	57                   	push   %edi
80108504:	56                   	push   %esi
80108505:	53                   	push   %ebx
80108506:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
80108509:	83 ec 0c             	sub    $0xc,%esp
8010850c:	6a 00                	push   $0x0
8010850e:	e8 e8 04 00 00       	call   801089fb <i8254_read_eeprom>
80108513:	83 c4 10             	add    $0x10,%esp
80108516:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
80108519:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010851c:	a2 80 6d 19 80       	mov    %al,0x80196d80
  mac_addr[1] = data_l>>8;
80108521:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108524:	c1 e8 08             	shr    $0x8,%eax
80108527:	a2 81 6d 19 80       	mov    %al,0x80196d81
  uint data_m = i8254_read_eeprom(0x1);
8010852c:	83 ec 0c             	sub    $0xc,%esp
8010852f:	6a 01                	push   $0x1
80108531:	e8 c5 04 00 00       	call   801089fb <i8254_read_eeprom>
80108536:	83 c4 10             	add    $0x10,%esp
80108539:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
8010853c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010853f:	a2 82 6d 19 80       	mov    %al,0x80196d82
  mac_addr[3] = data_m>>8;
80108544:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108547:	c1 e8 08             	shr    $0x8,%eax
8010854a:	a2 83 6d 19 80       	mov    %al,0x80196d83
  uint data_h = i8254_read_eeprom(0x2);
8010854f:	83 ec 0c             	sub    $0xc,%esp
80108552:	6a 02                	push   $0x2
80108554:	e8 a2 04 00 00       	call   801089fb <i8254_read_eeprom>
80108559:	83 c4 10             	add    $0x10,%esp
8010855c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010855f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108562:	a2 84 6d 19 80       	mov    %al,0x80196d84
  mac_addr[5] = data_h>>8;
80108567:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010856a:	c1 e8 08             	shr    $0x8,%eax
8010856d:	a2 85 6d 19 80       	mov    %al,0x80196d85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108572:	0f b6 05 85 6d 19 80 	movzbl 0x80196d85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108579:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010857c:	0f b6 05 84 6d 19 80 	movzbl 0x80196d84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108583:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108586:	0f b6 05 83 6d 19 80 	movzbl 0x80196d83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010858d:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108590:	0f b6 05 82 6d 19 80 	movzbl 0x80196d82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108597:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010859a:	0f b6 05 81 6d 19 80 	movzbl 0x80196d81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801085a1:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
801085a4:	0f b6 05 80 6d 19 80 	movzbl 0x80196d80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
801085ab:	0f b6 c0             	movzbl %al,%eax
801085ae:	83 ec 04             	sub    $0x4,%esp
801085b1:	57                   	push   %edi
801085b2:	56                   	push   %esi
801085b3:	53                   	push   %ebx
801085b4:	51                   	push   %ecx
801085b5:	52                   	push   %edx
801085b6:	50                   	push   %eax
801085b7:	68 78 be 10 80       	push   $0x8010be78
801085bc:	e8 33 7e ff ff       	call   801003f4 <cprintf>
801085c1:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
801085c4:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801085c9:	05 00 54 00 00       	add    $0x5400,%eax
801085ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
801085d1:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801085d6:	05 04 54 00 00       	add    $0x5404,%eax
801085db:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801085de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085e1:	c1 e0 10             	shl    $0x10,%eax
801085e4:	0b 45 d8             	or     -0x28(%ebp),%eax
801085e7:	89 c2                	mov    %eax,%edx
801085e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801085ec:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801085ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
801085f1:	0d 00 00 00 80       	or     $0x80000000,%eax
801085f6:	89 c2                	mov    %eax,%edx
801085f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801085fb:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801085fd:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108602:	05 00 52 00 00       	add    $0x5200,%eax
80108607:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
8010860a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108611:	eb 19                	jmp    8010862c <i8254_init_recv+0x12c>
    mta[i] = 0;
80108613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108616:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010861d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108620:	01 d0                	add    %edx,%eax
80108622:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108628:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010862c:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108630:	7e e1                	jle    80108613 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108632:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108637:	05 d0 00 00 00       	add    $0xd0,%eax
8010863c:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
8010863f:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108642:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108648:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010864d:	05 c8 00 00 00       	add    $0xc8,%eax
80108652:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108655:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108658:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010865e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108663:	05 28 28 00 00       	add    $0x2828,%eax
80108668:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010866b:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010866e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108674:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108679:	05 00 01 00 00       	add    $0x100,%eax
8010867e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108681:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108684:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010868a:	e8 19 a1 ff ff       	call   801027a8 <kalloc>
8010868f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108692:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108697:	05 00 28 00 00       	add    $0x2800,%eax
8010869c:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010869f:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801086a4:	05 04 28 00 00       	add    $0x2804,%eax
801086a9:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
801086ac:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801086b1:	05 08 28 00 00       	add    $0x2808,%eax
801086b6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
801086b9:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801086be:	05 10 28 00 00       	add    $0x2810,%eax
801086c3:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
801086c6:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801086cb:	05 18 28 00 00       	add    $0x2818,%eax
801086d0:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
801086d3:	8b 45 b0             	mov    -0x50(%ebp),%eax
801086d6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801086dc:	8b 45 ac             	mov    -0x54(%ebp),%eax
801086df:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801086e1:	8b 45 a8             	mov    -0x58(%ebp),%eax
801086e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801086ea:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801086ed:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801086f3:	8b 45 a0             	mov    -0x60(%ebp),%eax
801086f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801086fc:	8b 45 9c             	mov    -0x64(%ebp),%eax
801086ff:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108705:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108708:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
8010870b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108712:	eb 73                	jmp    80108787 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108714:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108717:	c1 e0 04             	shl    $0x4,%eax
8010871a:	89 c2                	mov    %eax,%edx
8010871c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010871f:	01 d0                	add    %edx,%eax
80108721:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108728:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010872b:	c1 e0 04             	shl    $0x4,%eax
8010872e:	89 c2                	mov    %eax,%edx
80108730:	8b 45 98             	mov    -0x68(%ebp),%eax
80108733:	01 d0                	add    %edx,%eax
80108735:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
8010873b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010873e:	c1 e0 04             	shl    $0x4,%eax
80108741:	89 c2                	mov    %eax,%edx
80108743:	8b 45 98             	mov    -0x68(%ebp),%eax
80108746:	01 d0                	add    %edx,%eax
80108748:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
8010874e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108751:	c1 e0 04             	shl    $0x4,%eax
80108754:	89 c2                	mov    %eax,%edx
80108756:	8b 45 98             	mov    -0x68(%ebp),%eax
80108759:	01 d0                	add    %edx,%eax
8010875b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010875f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108762:	c1 e0 04             	shl    $0x4,%eax
80108765:	89 c2                	mov    %eax,%edx
80108767:	8b 45 98             	mov    -0x68(%ebp),%eax
8010876a:	01 d0                	add    %edx,%eax
8010876c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108770:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108773:	c1 e0 04             	shl    $0x4,%eax
80108776:	89 c2                	mov    %eax,%edx
80108778:	8b 45 98             	mov    -0x68(%ebp),%eax
8010877b:	01 d0                	add    %edx,%eax
8010877d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108783:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108787:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010878e:	7e 84                	jle    80108714 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108790:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108797:	eb 57                	jmp    801087f0 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108799:	e8 0a a0 ff ff       	call   801027a8 <kalloc>
8010879e:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
801087a1:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
801087a5:	75 12                	jne    801087b9 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
801087a7:	83 ec 0c             	sub    $0xc,%esp
801087aa:	68 98 be 10 80       	push   $0x8010be98
801087af:	e8 40 7c ff ff       	call   801003f4 <cprintf>
801087b4:	83 c4 10             	add    $0x10,%esp
      break;
801087b7:	eb 3d                	jmp    801087f6 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
801087b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801087bc:	c1 e0 04             	shl    $0x4,%eax
801087bf:	89 c2                	mov    %eax,%edx
801087c1:	8b 45 98             	mov    -0x68(%ebp),%eax
801087c4:	01 d0                	add    %edx,%eax
801087c6:	8b 55 94             	mov    -0x6c(%ebp),%edx
801087c9:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801087cf:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
801087d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801087d4:	83 c0 01             	add    $0x1,%eax
801087d7:	c1 e0 04             	shl    $0x4,%eax
801087da:	89 c2                	mov    %eax,%edx
801087dc:	8b 45 98             	mov    -0x68(%ebp),%eax
801087df:	01 d0                	add    %edx,%eax
801087e1:	8b 55 94             	mov    -0x6c(%ebp),%edx
801087e4:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801087ea:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801087ec:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801087f0:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801087f4:	7e a3                	jle    80108799 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801087f6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087f9:	8b 00                	mov    (%eax),%eax
801087fb:	83 c8 02             	or     $0x2,%eax
801087fe:	89 c2                	mov    %eax,%edx
80108800:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108803:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108805:	83 ec 0c             	sub    $0xc,%esp
80108808:	68 b8 be 10 80       	push   $0x8010beb8
8010880d:	e8 e2 7b ff ff       	call   801003f4 <cprintf>
80108812:	83 c4 10             	add    $0x10,%esp
}
80108815:	90                   	nop
80108816:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108819:	5b                   	pop    %ebx
8010881a:	5e                   	pop    %esi
8010881b:	5f                   	pop    %edi
8010881c:	5d                   	pop    %ebp
8010881d:	c3                   	ret

8010881e <i8254_init_send>:

void i8254_init_send(){
8010881e:	55                   	push   %ebp
8010881f:	89 e5                	mov    %esp,%ebp
80108821:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108824:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108829:	05 28 38 00 00       	add    $0x3828,%eax
8010882e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108831:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108834:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
8010883a:	e8 69 9f ff ff       	call   801027a8 <kalloc>
8010883f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108842:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108847:	05 00 38 00 00       	add    $0x3800,%eax
8010884c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
8010884f:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108854:	05 04 38 00 00       	add    $0x3804,%eax
80108859:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010885c:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108861:	05 08 38 00 00       	add    $0x3808,%eax
80108866:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108869:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010886c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108872:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108875:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108877:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010887a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108880:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108883:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108889:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010888e:	05 10 38 00 00       	add    $0x3810,%eax
80108893:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108896:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010889b:	05 18 38 00 00       	add    $0x3818,%eax
801088a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
801088a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801088a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
801088ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801088af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
801088b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
801088bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088c2:	e9 82 00 00 00       	jmp    80108949 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	c1 e0 04             	shl    $0x4,%eax
801088cd:	89 c2                	mov    %eax,%edx
801088cf:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088d2:	01 d0                	add    %edx,%eax
801088d4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
801088db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088de:	c1 e0 04             	shl    $0x4,%eax
801088e1:	89 c2                	mov    %eax,%edx
801088e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088e6:	01 d0                	add    %edx,%eax
801088e8:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801088ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f1:	c1 e0 04             	shl    $0x4,%eax
801088f4:	89 c2                	mov    %eax,%edx
801088f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088f9:	01 d0                	add    %edx,%eax
801088fb:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801088ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108902:	c1 e0 04             	shl    $0x4,%eax
80108905:	89 c2                	mov    %eax,%edx
80108907:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010890a:	01 d0                	add    %edx,%eax
8010890c:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108913:	c1 e0 04             	shl    $0x4,%eax
80108916:	89 c2                	mov    %eax,%edx
80108918:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010891b:	01 d0                	add    %edx,%eax
8010891d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108924:	c1 e0 04             	shl    $0x4,%eax
80108927:	89 c2                	mov    %eax,%edx
80108929:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010892c:	01 d0                	add    %edx,%eax
8010892e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108935:	c1 e0 04             	shl    $0x4,%eax
80108938:	89 c2                	mov    %eax,%edx
8010893a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010893d:	01 d0                	add    %edx,%eax
8010893f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108945:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108949:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108950:	0f 8e 71 ff ff ff    	jle    801088c7 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108956:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010895d:	eb 57                	jmp    801089b6 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
8010895f:	e8 44 9e ff ff       	call   801027a8 <kalloc>
80108964:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108967:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010896b:	75 12                	jne    8010897f <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
8010896d:	83 ec 0c             	sub    $0xc,%esp
80108970:	68 98 be 10 80       	push   $0x8010be98
80108975:	e8 7a 7a ff ff       	call   801003f4 <cprintf>
8010897a:	83 c4 10             	add    $0x10,%esp
      break;
8010897d:	eb 3d                	jmp    801089bc <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
8010897f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108982:	c1 e0 04             	shl    $0x4,%eax
80108985:	89 c2                	mov    %eax,%edx
80108987:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010898a:	01 d0                	add    %edx,%eax
8010898c:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010898f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108995:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108997:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010899a:	83 c0 01             	add    $0x1,%eax
8010899d:	c1 e0 04             	shl    $0x4,%eax
801089a0:	89 c2                	mov    %eax,%edx
801089a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089a5:	01 d0                	add    %edx,%eax
801089a7:	8b 55 cc             	mov    -0x34(%ebp),%edx
801089aa:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801089b0:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
801089b2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801089b6:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801089ba:	7e a3                	jle    8010895f <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
801089bc:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801089c1:	05 00 04 00 00       	add    $0x400,%eax
801089c6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
801089c9:	8b 45 c8             	mov    -0x38(%ebp),%eax
801089cc:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
801089d2:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801089d7:	05 10 04 00 00       	add    $0x410,%eax
801089dc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801089df:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801089e2:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801089e8:	83 ec 0c             	sub    $0xc,%esp
801089eb:	68 d8 be 10 80       	push   $0x8010bed8
801089f0:	e8 ff 79 ff ff       	call   801003f4 <cprintf>
801089f5:	83 c4 10             	add    $0x10,%esp

}
801089f8:	90                   	nop
801089f9:	c9                   	leave
801089fa:	c3                   	ret

801089fb <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801089fb:	55                   	push   %ebp
801089fc:	89 e5                	mov    %esp,%ebp
801089fe:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108a01:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a06:	83 c0 14             	add    $0x14,%eax
80108a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80108a0f:	c1 e0 08             	shl    $0x8,%eax
80108a12:	0f b7 c0             	movzwl %ax,%eax
80108a15:	83 c8 01             	or     $0x1,%eax
80108a18:	89 c2                	mov    %eax,%edx
80108a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1d:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108a1f:	83 ec 0c             	sub    $0xc,%esp
80108a22:	68 f8 be 10 80       	push   $0x8010bef8
80108a27:	e8 c8 79 ff ff       	call   801003f4 <cprintf>
80108a2c:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a32:	8b 00                	mov    (%eax),%eax
80108a34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a3a:	83 e0 10             	and    $0x10,%eax
80108a3d:	85 c0                	test   %eax,%eax
80108a3f:	75 02                	jne    80108a43 <i8254_read_eeprom+0x48>
  while(1){
80108a41:	eb dc                	jmp    80108a1f <i8254_read_eeprom+0x24>
      break;
80108a43:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a47:	8b 00                	mov    (%eax),%eax
80108a49:	c1 e8 10             	shr    $0x10,%eax
}
80108a4c:	c9                   	leave
80108a4d:	c3                   	ret

80108a4e <i8254_recv>:
void i8254_recv(){
80108a4e:	55                   	push   %ebp
80108a4f:	89 e5                	mov    %esp,%ebp
80108a51:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108a54:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a59:	05 10 28 00 00       	add    $0x2810,%eax
80108a5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108a61:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a66:	05 18 28 00 00       	add    $0x2818,%eax
80108a6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a6e:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a73:	05 00 28 00 00       	add    $0x2800,%eax
80108a78:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108a7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a7e:	8b 00                	mov    (%eax),%eax
80108a80:	05 00 00 00 80       	add    $0x80000000,%eax
80108a85:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8b:	8b 10                	mov    (%eax),%edx
80108a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a90:	8b 00                	mov    (%eax),%eax
80108a92:	29 c2                	sub    %eax,%edx
80108a94:	89 d0                	mov    %edx,%eax
80108a96:	25 ff 00 00 00       	and    $0xff,%eax
80108a9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108a9e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108aa2:	7e 37                	jle    80108adb <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa7:	8b 00                	mov    (%eax),%eax
80108aa9:	c1 e0 04             	shl    $0x4,%eax
80108aac:	89 c2                	mov    %eax,%edx
80108aae:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ab1:	01 d0                	add    %edx,%eax
80108ab3:	8b 00                	mov    (%eax),%eax
80108ab5:	05 00 00 00 80       	add    $0x80000000,%eax
80108aba:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ac0:	8b 00                	mov    (%eax),%eax
80108ac2:	83 c0 01             	add    $0x1,%eax
80108ac5:	0f b6 d0             	movzbl %al,%edx
80108ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108acb:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108acd:	83 ec 0c             	sub    $0xc,%esp
80108ad0:	ff 75 e0             	push   -0x20(%ebp)
80108ad3:	e8 13 09 00 00       	call   801093eb <eth_proc>
80108ad8:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ade:	8b 10                	mov    (%eax),%edx
80108ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae3:	8b 00                	mov    (%eax),%eax
80108ae5:	39 c2                	cmp    %eax,%edx
80108ae7:	75 9f                	jne    80108a88 <i8254_recv+0x3a>
      (*rdt)--;
80108ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aec:	8b 00                	mov    (%eax),%eax
80108aee:	8d 50 ff             	lea    -0x1(%eax),%edx
80108af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af4:	89 10                	mov    %edx,(%eax)
  while(1){
80108af6:	eb 90                	jmp    80108a88 <i8254_recv+0x3a>

80108af8 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108af8:	55                   	push   %ebp
80108af9:	89 e5                	mov    %esp,%ebp
80108afb:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108afe:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b03:	05 10 38 00 00       	add    $0x3810,%eax
80108b08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108b0b:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b10:	05 18 38 00 00       	add    $0x3818,%eax
80108b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108b18:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108b1d:	05 00 38 00 00       	add    $0x3800,%eax
80108b22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108b25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b28:	8b 00                	mov    (%eax),%eax
80108b2a:	05 00 00 00 80       	add    $0x80000000,%eax
80108b2f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b35:	8b 10                	mov    (%eax),%edx
80108b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b3a:	8b 00                	mov    (%eax),%eax
80108b3c:	29 c2                	sub    %eax,%edx
80108b3e:	0f b6 c2             	movzbl %dl,%eax
80108b41:	ba 00 01 00 00       	mov    $0x100,%edx
80108b46:	29 c2                	sub    %eax,%edx
80108b48:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b4e:	8b 00                	mov    (%eax),%eax
80108b50:	25 ff 00 00 00       	and    $0xff,%eax
80108b55:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108b58:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b5c:	0f 8e a8 00 00 00    	jle    80108c0a <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108b62:	8b 45 08             	mov    0x8(%ebp),%eax
80108b65:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108b68:	89 d1                	mov    %edx,%ecx
80108b6a:	c1 e1 04             	shl    $0x4,%ecx
80108b6d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108b70:	01 ca                	add    %ecx,%edx
80108b72:	8b 12                	mov    (%edx),%edx
80108b74:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b7a:	83 ec 04             	sub    $0x4,%esp
80108b7d:	ff 75 0c             	push   0xc(%ebp)
80108b80:	50                   	push   %eax
80108b81:	52                   	push   %edx
80108b82:	e8 d3 be ff ff       	call   80104a5a <memmove>
80108b87:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108b8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b8d:	c1 e0 04             	shl    $0x4,%eax
80108b90:	89 c2                	mov    %eax,%edx
80108b92:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b95:	01 d0                	add    %edx,%eax
80108b97:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b9a:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108b9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ba1:	c1 e0 04             	shl    $0x4,%eax
80108ba4:	89 c2                	mov    %eax,%edx
80108ba6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ba9:	01 d0                	add    %edx,%eax
80108bab:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108baf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bb2:	c1 e0 04             	shl    $0x4,%eax
80108bb5:	89 c2                	mov    %eax,%edx
80108bb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bba:	01 d0                	add    %edx,%eax
80108bbc:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108bc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bc3:	c1 e0 04             	shl    $0x4,%eax
80108bc6:	89 c2                	mov    %eax,%edx
80108bc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bcb:	01 d0                	add    %edx,%eax
80108bcd:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108bd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bd4:	c1 e0 04             	shl    $0x4,%eax
80108bd7:	89 c2                	mov    %eax,%edx
80108bd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bdc:	01 d0                	add    %edx,%eax
80108bde:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108be4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108be7:	c1 e0 04             	shl    $0x4,%eax
80108bea:	89 c2                	mov    %eax,%edx
80108bec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bef:	01 d0                	add    %edx,%eax
80108bf1:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bf8:	8b 00                	mov    (%eax),%eax
80108bfa:	83 c0 01             	add    $0x1,%eax
80108bfd:	0f b6 d0             	movzbl %al,%edx
80108c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c03:	89 10                	mov    %edx,(%eax)
    return len;
80108c05:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c08:	eb 05                	jmp    80108c0f <i8254_send+0x117>
  }else{
    return -1;
80108c0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108c0f:	c9                   	leave
80108c10:	c3                   	ret

80108c11 <i8254_intr>:

void i8254_intr(){
80108c11:	55                   	push   %ebp
80108c12:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108c14:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108c19:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108c1f:	90                   	nop
80108c20:	5d                   	pop    %ebp
80108c21:	c3                   	ret

80108c22 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108c22:	55                   	push   %ebp
80108c23:	89 e5                	mov    %esp,%ebp
80108c25:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108c28:	8b 45 08             	mov    0x8(%ebp),%eax
80108c2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c31:	0f b7 00             	movzwl (%eax),%eax
80108c34:	66 3d 00 01          	cmp    $0x100,%ax
80108c38:	74 0a                	je     80108c44 <arp_proc+0x22>
80108c3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c3f:	e9 4f 01 00 00       	jmp    80108d93 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c47:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108c4b:	66 83 f8 08          	cmp    $0x8,%ax
80108c4f:	74 0a                	je     80108c5b <arp_proc+0x39>
80108c51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c56:	e9 38 01 00 00       	jmp    80108d93 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c5e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108c62:	3c 06                	cmp    $0x6,%al
80108c64:	74 0a                	je     80108c70 <arp_proc+0x4e>
80108c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c6b:	e9 23 01 00 00       	jmp    80108d93 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c73:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108c77:	3c 04                	cmp    $0x4,%al
80108c79:	74 0a                	je     80108c85 <arp_proc+0x63>
80108c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c80:	e9 0e 01 00 00       	jmp    80108d93 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c88:	83 c0 18             	add    $0x18,%eax
80108c8b:	83 ec 04             	sub    $0x4,%esp
80108c8e:	6a 04                	push   $0x4
80108c90:	50                   	push   %eax
80108c91:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c96:	e8 67 bd ff ff       	call   80104a02 <memcmp>
80108c9b:	83 c4 10             	add    $0x10,%esp
80108c9e:	85 c0                	test   %eax,%eax
80108ca0:	74 27                	je     80108cc9 <arp_proc+0xa7>
80108ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ca5:	83 c0 0e             	add    $0xe,%eax
80108ca8:	83 ec 04             	sub    $0x4,%esp
80108cab:	6a 04                	push   $0x4
80108cad:	50                   	push   %eax
80108cae:	68 e4 f4 10 80       	push   $0x8010f4e4
80108cb3:	e8 4a bd ff ff       	call   80104a02 <memcmp>
80108cb8:	83 c4 10             	add    $0x10,%esp
80108cbb:	85 c0                	test   %eax,%eax
80108cbd:	74 0a                	je     80108cc9 <arp_proc+0xa7>
80108cbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cc4:	e9 ca 00 00 00       	jmp    80108d93 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ccc:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108cd0:	66 3d 00 01          	cmp    $0x100,%ax
80108cd4:	75 69                	jne    80108d3f <arp_proc+0x11d>
80108cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd9:	83 c0 18             	add    $0x18,%eax
80108cdc:	83 ec 04             	sub    $0x4,%esp
80108cdf:	6a 04                	push   $0x4
80108ce1:	50                   	push   %eax
80108ce2:	68 e4 f4 10 80       	push   $0x8010f4e4
80108ce7:	e8 16 bd ff ff       	call   80104a02 <memcmp>
80108cec:	83 c4 10             	add    $0x10,%esp
80108cef:	85 c0                	test   %eax,%eax
80108cf1:	75 4c                	jne    80108d3f <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108cf3:	e8 b0 9a ff ff       	call   801027a8 <kalloc>
80108cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108cfb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108d02:	83 ec 04             	sub    $0x4,%esp
80108d05:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108d08:	50                   	push   %eax
80108d09:	ff 75 f0             	push   -0x10(%ebp)
80108d0c:	ff 75 f4             	push   -0xc(%ebp)
80108d0f:	e8 1f 04 00 00       	call   80109133 <arp_reply_pkt_create>
80108d14:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108d17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d1a:	83 ec 08             	sub    $0x8,%esp
80108d1d:	50                   	push   %eax
80108d1e:	ff 75 f0             	push   -0x10(%ebp)
80108d21:	e8 d2 fd ff ff       	call   80108af8 <i8254_send>
80108d26:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d2c:	83 ec 0c             	sub    $0xc,%esp
80108d2f:	50                   	push   %eax
80108d30:	e8 d9 99 ff ff       	call   8010270e <kfree>
80108d35:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108d38:	b8 02 00 00 00       	mov    $0x2,%eax
80108d3d:	eb 54                	jmp    80108d93 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d42:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108d46:	66 3d 00 02          	cmp    $0x200,%ax
80108d4a:	75 42                	jne    80108d8e <arp_proc+0x16c>
80108d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4f:	83 c0 18             	add    $0x18,%eax
80108d52:	83 ec 04             	sub    $0x4,%esp
80108d55:	6a 04                	push   $0x4
80108d57:	50                   	push   %eax
80108d58:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d5d:	e8 a0 bc ff ff       	call   80104a02 <memcmp>
80108d62:	83 c4 10             	add    $0x10,%esp
80108d65:	85 c0                	test   %eax,%eax
80108d67:	75 25                	jne    80108d8e <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108d69:	83 ec 0c             	sub    $0xc,%esp
80108d6c:	68 fc be 10 80       	push   $0x8010befc
80108d71:	e8 7e 76 ff ff       	call   801003f4 <cprintf>
80108d76:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108d79:	83 ec 0c             	sub    $0xc,%esp
80108d7c:	ff 75 f4             	push   -0xc(%ebp)
80108d7f:	e8 af 01 00 00       	call   80108f33 <arp_table_update>
80108d84:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108d87:	b8 01 00 00 00       	mov    $0x1,%eax
80108d8c:	eb 05                	jmp    80108d93 <arp_proc+0x171>
  }else{
    return -1;
80108d8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108d93:	c9                   	leave
80108d94:	c3                   	ret

80108d95 <arp_scan>:

void arp_scan(){
80108d95:	55                   	push   %ebp
80108d96:	89 e5                	mov    %esp,%ebp
80108d98:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108d9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108da2:	eb 6f                	jmp    80108e13 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108da4:	e8 ff 99 ff ff       	call   801027a8 <kalloc>
80108da9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108dac:	83 ec 04             	sub    $0x4,%esp
80108daf:	ff 75 f4             	push   -0xc(%ebp)
80108db2:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108db5:	50                   	push   %eax
80108db6:	ff 75 ec             	push   -0x14(%ebp)
80108db9:	e8 62 00 00 00       	call   80108e20 <arp_broadcast>
80108dbe:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108dc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dc4:	83 ec 08             	sub    $0x8,%esp
80108dc7:	50                   	push   %eax
80108dc8:	ff 75 ec             	push   -0x14(%ebp)
80108dcb:	e8 28 fd ff ff       	call   80108af8 <i8254_send>
80108dd0:	83 c4 10             	add    $0x10,%esp
80108dd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108dd6:	eb 22                	jmp    80108dfa <arp_scan+0x65>
      microdelay(1);
80108dd8:	83 ec 0c             	sub    $0xc,%esp
80108ddb:	6a 01                	push   $0x1
80108ddd:	e8 57 9d ff ff       	call   80102b39 <microdelay>
80108de2:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108de5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108de8:	83 ec 08             	sub    $0x8,%esp
80108deb:	50                   	push   %eax
80108dec:	ff 75 ec             	push   -0x14(%ebp)
80108def:	e8 04 fd ff ff       	call   80108af8 <i8254_send>
80108df4:	83 c4 10             	add    $0x10,%esp
80108df7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108dfa:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108dfe:	74 d8                	je     80108dd8 <arp_scan+0x43>
    }
    kfree((char *)send);
80108e00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e03:	83 ec 0c             	sub    $0xc,%esp
80108e06:	50                   	push   %eax
80108e07:	e8 02 99 ff ff       	call   8010270e <kfree>
80108e0c:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108e0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e13:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e1a:	7e 88                	jle    80108da4 <arp_scan+0xf>
  }
}
80108e1c:	90                   	nop
80108e1d:	90                   	nop
80108e1e:	c9                   	leave
80108e1f:	c3                   	ret

80108e20 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108e20:	55                   	push   %ebp
80108e21:	89 e5                	mov    %esp,%ebp
80108e23:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108e26:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108e2a:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108e2e:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108e32:	8b 45 10             	mov    0x10(%ebp),%eax
80108e35:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108e38:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108e3f:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108e45:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e4c:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108e52:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e55:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80108e5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108e61:	8b 45 08             	mov    0x8(%ebp),%eax
80108e64:	83 c0 0e             	add    $0xe,%eax
80108e67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e6d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e74:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e7b:	83 ec 04             	sub    $0x4,%esp
80108e7e:	6a 06                	push   $0x6
80108e80:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108e83:	52                   	push   %edx
80108e84:	50                   	push   %eax
80108e85:	e8 d0 bb ff ff       	call   80104a5a <memmove>
80108e8a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e90:	83 c0 06             	add    $0x6,%eax
80108e93:	83 ec 04             	sub    $0x4,%esp
80108e96:	6a 06                	push   $0x6
80108e98:	68 80 6d 19 80       	push   $0x80196d80
80108e9d:	50                   	push   %eax
80108e9e:	e8 b7 bb ff ff       	call   80104a5a <memmove>
80108ea3:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ea9:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb1:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eba:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec1:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec8:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ed1:	8d 50 12             	lea    0x12(%eax),%edx
80108ed4:	83 ec 04             	sub    $0x4,%esp
80108ed7:	6a 06                	push   $0x6
80108ed9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108edc:	50                   	push   %eax
80108edd:	52                   	push   %edx
80108ede:	e8 77 bb ff ff       	call   80104a5a <memmove>
80108ee3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ee9:	8d 50 18             	lea    0x18(%eax),%edx
80108eec:	83 ec 04             	sub    $0x4,%esp
80108eef:	6a 04                	push   $0x4
80108ef1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ef4:	50                   	push   %eax
80108ef5:	52                   	push   %edx
80108ef6:	e8 5f bb ff ff       	call   80104a5a <memmove>
80108efb:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108efe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f01:	83 c0 08             	add    $0x8,%eax
80108f04:	83 ec 04             	sub    $0x4,%esp
80108f07:	6a 06                	push   $0x6
80108f09:	68 80 6d 19 80       	push   $0x80196d80
80108f0e:	50                   	push   %eax
80108f0f:	e8 46 bb ff ff       	call   80104a5a <memmove>
80108f14:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1a:	83 c0 0e             	add    $0xe,%eax
80108f1d:	83 ec 04             	sub    $0x4,%esp
80108f20:	6a 04                	push   $0x4
80108f22:	68 e4 f4 10 80       	push   $0x8010f4e4
80108f27:	50                   	push   %eax
80108f28:	e8 2d bb ff ff       	call   80104a5a <memmove>
80108f2d:	83 c4 10             	add    $0x10,%esp
}
80108f30:	90                   	nop
80108f31:	c9                   	leave
80108f32:	c3                   	ret

80108f33 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108f33:	55                   	push   %ebp
80108f34:	89 e5                	mov    %esp,%ebp
80108f36:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108f39:	8b 45 08             	mov    0x8(%ebp),%eax
80108f3c:	83 c0 0e             	add    $0xe,%eax
80108f3f:	83 ec 0c             	sub    $0xc,%esp
80108f42:	50                   	push   %eax
80108f43:	e8 bc 00 00 00       	call   80109004 <arp_table_search>
80108f48:	83 c4 10             	add    $0x10,%esp
80108f4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108f4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f52:	78 2d                	js     80108f81 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f54:	8b 45 08             	mov    0x8(%ebp),%eax
80108f57:	8d 48 08             	lea    0x8(%eax),%ecx
80108f5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f5d:	89 d0                	mov    %edx,%eax
80108f5f:	c1 e0 02             	shl    $0x2,%eax
80108f62:	01 d0                	add    %edx,%eax
80108f64:	01 c0                	add    %eax,%eax
80108f66:	01 d0                	add    %edx,%eax
80108f68:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108f6d:	83 c0 04             	add    $0x4,%eax
80108f70:	83 ec 04             	sub    $0x4,%esp
80108f73:	6a 06                	push   $0x6
80108f75:	51                   	push   %ecx
80108f76:	50                   	push   %eax
80108f77:	e8 de ba ff ff       	call   80104a5a <memmove>
80108f7c:	83 c4 10             	add    $0x10,%esp
80108f7f:	eb 70                	jmp    80108ff1 <arp_table_update+0xbe>
  }else{
    index += 1;
80108f81:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80108f85:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f88:	8b 45 08             	mov    0x8(%ebp),%eax
80108f8b:	8d 48 08             	lea    0x8(%eax),%ecx
80108f8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f91:	89 d0                	mov    %edx,%eax
80108f93:	c1 e0 02             	shl    $0x2,%eax
80108f96:	01 d0                	add    %edx,%eax
80108f98:	01 c0                	add    %eax,%eax
80108f9a:	01 d0                	add    %edx,%eax
80108f9c:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108fa1:	83 c0 04             	add    $0x4,%eax
80108fa4:	83 ec 04             	sub    $0x4,%esp
80108fa7:	6a 06                	push   $0x6
80108fa9:	51                   	push   %ecx
80108faa:	50                   	push   %eax
80108fab:	e8 aa ba ff ff       	call   80104a5a <memmove>
80108fb0:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80108fb3:	8b 45 08             	mov    0x8(%ebp),%eax
80108fb6:	8d 48 0e             	lea    0xe(%eax),%ecx
80108fb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fbc:	89 d0                	mov    %edx,%eax
80108fbe:	c1 e0 02             	shl    $0x2,%eax
80108fc1:	01 d0                	add    %edx,%eax
80108fc3:	01 c0                	add    %eax,%eax
80108fc5:	01 d0                	add    %edx,%eax
80108fc7:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108fcc:	83 ec 04             	sub    $0x4,%esp
80108fcf:	6a 04                	push   $0x4
80108fd1:	51                   	push   %ecx
80108fd2:	50                   	push   %eax
80108fd3:	e8 82 ba ff ff       	call   80104a5a <memmove>
80108fd8:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80108fdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fde:	89 d0                	mov    %edx,%eax
80108fe0:	c1 e0 02             	shl    $0x2,%eax
80108fe3:	01 d0                	add    %edx,%eax
80108fe5:	01 c0                	add    %eax,%eax
80108fe7:	01 d0                	add    %edx,%eax
80108fe9:	05 aa 6d 19 80       	add    $0x80196daa,%eax
80108fee:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80108ff1:	83 ec 0c             	sub    $0xc,%esp
80108ff4:	68 a0 6d 19 80       	push   $0x80196da0
80108ff9:	e8 83 00 00 00       	call   80109081 <print_arp_table>
80108ffe:	83 c4 10             	add    $0x10,%esp
}
80109001:	90                   	nop
80109002:	c9                   	leave
80109003:	c3                   	ret

80109004 <arp_table_search>:

int arp_table_search(uchar *ip){
80109004:	55                   	push   %ebp
80109005:	89 e5                	mov    %esp,%ebp
80109007:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
8010900a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109011:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109018:	eb 59                	jmp    80109073 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
8010901a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010901d:	89 d0                	mov    %edx,%eax
8010901f:	c1 e0 02             	shl    $0x2,%eax
80109022:	01 d0                	add    %edx,%eax
80109024:	01 c0                	add    %eax,%eax
80109026:	01 d0                	add    %edx,%eax
80109028:	05 a0 6d 19 80       	add    $0x80196da0,%eax
8010902d:	83 ec 04             	sub    $0x4,%esp
80109030:	6a 04                	push   $0x4
80109032:	ff 75 08             	push   0x8(%ebp)
80109035:	50                   	push   %eax
80109036:	e8 c7 b9 ff ff       	call   80104a02 <memcmp>
8010903b:	83 c4 10             	add    $0x10,%esp
8010903e:	85 c0                	test   %eax,%eax
80109040:	75 05                	jne    80109047 <arp_table_search+0x43>
      return i;
80109042:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109045:	eb 38                	jmp    8010907f <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109047:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010904a:	89 d0                	mov    %edx,%eax
8010904c:	c1 e0 02             	shl    $0x2,%eax
8010904f:	01 d0                	add    %edx,%eax
80109051:	01 c0                	add    %eax,%eax
80109053:	01 d0                	add    %edx,%eax
80109055:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010905a:	0f b6 00             	movzbl (%eax),%eax
8010905d:	84 c0                	test   %al,%al
8010905f:	75 0e                	jne    8010906f <arp_table_search+0x6b>
80109061:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109065:	75 08                	jne    8010906f <arp_table_search+0x6b>
      empty = -i;
80109067:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010906a:	f7 d8                	neg    %eax
8010906c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010906f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109073:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109077:	7e a1                	jle    8010901a <arp_table_search+0x16>
    }
  }
  return empty-1;
80109079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010907c:	83 e8 01             	sub    $0x1,%eax
}
8010907f:	c9                   	leave
80109080:	c3                   	ret

80109081 <print_arp_table>:

void print_arp_table(){
80109081:	55                   	push   %ebp
80109082:	89 e5                	mov    %esp,%ebp
80109084:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109087:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010908e:	e9 92 00 00 00       	jmp    80109125 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109093:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109096:	89 d0                	mov    %edx,%eax
80109098:	c1 e0 02             	shl    $0x2,%eax
8010909b:	01 d0                	add    %edx,%eax
8010909d:	01 c0                	add    %eax,%eax
8010909f:	01 d0                	add    %edx,%eax
801090a1:	05 aa 6d 19 80       	add    $0x80196daa,%eax
801090a6:	0f b6 00             	movzbl (%eax),%eax
801090a9:	84 c0                	test   %al,%al
801090ab:	74 74                	je     80109121 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
801090ad:	83 ec 08             	sub    $0x8,%esp
801090b0:	ff 75 f4             	push   -0xc(%ebp)
801090b3:	68 0f bf 10 80       	push   $0x8010bf0f
801090b8:	e8 37 73 ff ff       	call   801003f4 <cprintf>
801090bd:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801090c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090c3:	89 d0                	mov    %edx,%eax
801090c5:	c1 e0 02             	shl    $0x2,%eax
801090c8:	01 d0                	add    %edx,%eax
801090ca:	01 c0                	add    %eax,%eax
801090cc:	01 d0                	add    %edx,%eax
801090ce:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801090d3:	83 ec 0c             	sub    $0xc,%esp
801090d6:	50                   	push   %eax
801090d7:	e8 54 02 00 00       	call   80109330 <print_ipv4>
801090dc:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801090df:	83 ec 0c             	sub    $0xc,%esp
801090e2:	68 1e bf 10 80       	push   $0x8010bf1e
801090e7:	e8 08 73 ff ff       	call   801003f4 <cprintf>
801090ec:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801090ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090f2:	89 d0                	mov    %edx,%eax
801090f4:	c1 e0 02             	shl    $0x2,%eax
801090f7:	01 d0                	add    %edx,%eax
801090f9:	01 c0                	add    %eax,%eax
801090fb:	01 d0                	add    %edx,%eax
801090fd:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109102:	83 c0 04             	add    $0x4,%eax
80109105:	83 ec 0c             	sub    $0xc,%esp
80109108:	50                   	push   %eax
80109109:	e8 70 02 00 00       	call   8010937e <print_mac>
8010910e:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
80109111:	83 ec 0c             	sub    $0xc,%esp
80109114:	68 20 bf 10 80       	push   $0x8010bf20
80109119:	e8 d6 72 ff ff       	call   801003f4 <cprintf>
8010911e:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109121:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109125:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
80109129:	0f 8e 64 ff ff ff    	jle    80109093 <print_arp_table+0x12>
    }
  }
}
8010912f:	90                   	nop
80109130:	90                   	nop
80109131:	c9                   	leave
80109132:	c3                   	ret

80109133 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109133:	55                   	push   %ebp
80109134:	89 e5                	mov    %esp,%ebp
80109136:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109139:	8b 45 10             	mov    0x10(%ebp),%eax
8010913c:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109142:	8b 45 0c             	mov    0xc(%ebp),%eax
80109145:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109148:	8b 45 0c             	mov    0xc(%ebp),%eax
8010914b:	83 c0 0e             	add    $0xe,%eax
8010914e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109154:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109158:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915b:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010915f:	8b 45 08             	mov    0x8(%ebp),%eax
80109162:	8d 50 08             	lea    0x8(%eax),%edx
80109165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109168:	83 ec 04             	sub    $0x4,%esp
8010916b:	6a 06                	push   $0x6
8010916d:	52                   	push   %edx
8010916e:	50                   	push   %eax
8010916f:	e8 e6 b8 ff ff       	call   80104a5a <memmove>
80109174:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917a:	83 c0 06             	add    $0x6,%eax
8010917d:	83 ec 04             	sub    $0x4,%esp
80109180:	6a 06                	push   $0x6
80109182:	68 80 6d 19 80       	push   $0x80196d80
80109187:	50                   	push   %eax
80109188:	e8 cd b8 ff ff       	call   80104a5a <memmove>
8010918d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109193:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109198:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010919b:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
801091a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a4:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801091a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ab:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
801091af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091b2:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
801091b8:	8b 45 08             	mov    0x8(%ebp),%eax
801091bb:	8d 50 08             	lea    0x8(%eax),%edx
801091be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091c1:	83 c0 12             	add    $0x12,%eax
801091c4:	83 ec 04             	sub    $0x4,%esp
801091c7:	6a 06                	push   $0x6
801091c9:	52                   	push   %edx
801091ca:	50                   	push   %eax
801091cb:	e8 8a b8 ff ff       	call   80104a5a <memmove>
801091d0:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801091d3:	8b 45 08             	mov    0x8(%ebp),%eax
801091d6:	8d 50 0e             	lea    0xe(%eax),%edx
801091d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091dc:	83 c0 18             	add    $0x18,%eax
801091df:	83 ec 04             	sub    $0x4,%esp
801091e2:	6a 04                	push   $0x4
801091e4:	52                   	push   %edx
801091e5:	50                   	push   %eax
801091e6:	e8 6f b8 ff ff       	call   80104a5a <memmove>
801091eb:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801091ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091f1:	83 c0 08             	add    $0x8,%eax
801091f4:	83 ec 04             	sub    $0x4,%esp
801091f7:	6a 06                	push   $0x6
801091f9:	68 80 6d 19 80       	push   $0x80196d80
801091fe:	50                   	push   %eax
801091ff:	e8 56 b8 ff ff       	call   80104a5a <memmove>
80109204:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80109207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010920a:	83 c0 0e             	add    $0xe,%eax
8010920d:	83 ec 04             	sub    $0x4,%esp
80109210:	6a 04                	push   $0x4
80109212:	68 e4 f4 10 80       	push   $0x8010f4e4
80109217:	50                   	push   %eax
80109218:	e8 3d b8 ff ff       	call   80104a5a <memmove>
8010921d:	83 c4 10             	add    $0x10,%esp
}
80109220:	90                   	nop
80109221:	c9                   	leave
80109222:	c3                   	ret

80109223 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109223:	55                   	push   %ebp
80109224:	89 e5                	mov    %esp,%ebp
80109226:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
80109229:	83 ec 0c             	sub    $0xc,%esp
8010922c:	68 22 bf 10 80       	push   $0x8010bf22
80109231:	e8 be 71 ff ff       	call   801003f4 <cprintf>
80109236:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
80109239:	8b 45 08             	mov    0x8(%ebp),%eax
8010923c:	83 c0 0e             	add    $0xe,%eax
8010923f:	83 ec 0c             	sub    $0xc,%esp
80109242:	50                   	push   %eax
80109243:	e8 e8 00 00 00       	call   80109330 <print_ipv4>
80109248:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010924b:	83 ec 0c             	sub    $0xc,%esp
8010924e:	68 20 bf 10 80       	push   $0x8010bf20
80109253:	e8 9c 71 ff ff       	call   801003f4 <cprintf>
80109258:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010925b:	8b 45 08             	mov    0x8(%ebp),%eax
8010925e:	83 c0 08             	add    $0x8,%eax
80109261:	83 ec 0c             	sub    $0xc,%esp
80109264:	50                   	push   %eax
80109265:	e8 14 01 00 00       	call   8010937e <print_mac>
8010926a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010926d:	83 ec 0c             	sub    $0xc,%esp
80109270:	68 20 bf 10 80       	push   $0x8010bf20
80109275:	e8 7a 71 ff ff       	call   801003f4 <cprintf>
8010927a:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010927d:	83 ec 0c             	sub    $0xc,%esp
80109280:	68 39 bf 10 80       	push   $0x8010bf39
80109285:	e8 6a 71 ff ff       	call   801003f4 <cprintf>
8010928a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010928d:	8b 45 08             	mov    0x8(%ebp),%eax
80109290:	83 c0 18             	add    $0x18,%eax
80109293:	83 ec 0c             	sub    $0xc,%esp
80109296:	50                   	push   %eax
80109297:	e8 94 00 00 00       	call   80109330 <print_ipv4>
8010929c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010929f:	83 ec 0c             	sub    $0xc,%esp
801092a2:	68 20 bf 10 80       	push   $0x8010bf20
801092a7:	e8 48 71 ff ff       	call   801003f4 <cprintf>
801092ac:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
801092af:	8b 45 08             	mov    0x8(%ebp),%eax
801092b2:	83 c0 12             	add    $0x12,%eax
801092b5:	83 ec 0c             	sub    $0xc,%esp
801092b8:	50                   	push   %eax
801092b9:	e8 c0 00 00 00       	call   8010937e <print_mac>
801092be:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801092c1:	83 ec 0c             	sub    $0xc,%esp
801092c4:	68 20 bf 10 80       	push   $0x8010bf20
801092c9:	e8 26 71 ff ff       	call   801003f4 <cprintf>
801092ce:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801092d1:	83 ec 0c             	sub    $0xc,%esp
801092d4:	68 50 bf 10 80       	push   $0x8010bf50
801092d9:	e8 16 71 ff ff       	call   801003f4 <cprintf>
801092de:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801092e1:	8b 45 08             	mov    0x8(%ebp),%eax
801092e4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092e8:	66 3d 00 01          	cmp    $0x100,%ax
801092ec:	75 12                	jne    80109300 <print_arp_info+0xdd>
801092ee:	83 ec 0c             	sub    $0xc,%esp
801092f1:	68 5c bf 10 80       	push   $0x8010bf5c
801092f6:	e8 f9 70 ff ff       	call   801003f4 <cprintf>
801092fb:	83 c4 10             	add    $0x10,%esp
801092fe:	eb 1d                	jmp    8010931d <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
80109300:	8b 45 08             	mov    0x8(%ebp),%eax
80109303:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109307:	66 3d 00 02          	cmp    $0x200,%ax
8010930b:	75 10                	jne    8010931d <print_arp_info+0xfa>
    cprintf("Reply\n");
8010930d:	83 ec 0c             	sub    $0xc,%esp
80109310:	68 65 bf 10 80       	push   $0x8010bf65
80109315:	e8 da 70 ff ff       	call   801003f4 <cprintf>
8010931a:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
8010931d:	83 ec 0c             	sub    $0xc,%esp
80109320:	68 20 bf 10 80       	push   $0x8010bf20
80109325:	e8 ca 70 ff ff       	call   801003f4 <cprintf>
8010932a:	83 c4 10             	add    $0x10,%esp
}
8010932d:	90                   	nop
8010932e:	c9                   	leave
8010932f:	c3                   	ret

80109330 <print_ipv4>:

void print_ipv4(uchar *ip){
80109330:	55                   	push   %ebp
80109331:	89 e5                	mov    %esp,%ebp
80109333:	53                   	push   %ebx
80109334:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109337:	8b 45 08             	mov    0x8(%ebp),%eax
8010933a:	83 c0 03             	add    $0x3,%eax
8010933d:	0f b6 00             	movzbl (%eax),%eax
80109340:	0f b6 d8             	movzbl %al,%ebx
80109343:	8b 45 08             	mov    0x8(%ebp),%eax
80109346:	83 c0 02             	add    $0x2,%eax
80109349:	0f b6 00             	movzbl (%eax),%eax
8010934c:	0f b6 c8             	movzbl %al,%ecx
8010934f:	8b 45 08             	mov    0x8(%ebp),%eax
80109352:	83 c0 01             	add    $0x1,%eax
80109355:	0f b6 00             	movzbl (%eax),%eax
80109358:	0f b6 d0             	movzbl %al,%edx
8010935b:	8b 45 08             	mov    0x8(%ebp),%eax
8010935e:	0f b6 00             	movzbl (%eax),%eax
80109361:	0f b6 c0             	movzbl %al,%eax
80109364:	83 ec 0c             	sub    $0xc,%esp
80109367:	53                   	push   %ebx
80109368:	51                   	push   %ecx
80109369:	52                   	push   %edx
8010936a:	50                   	push   %eax
8010936b:	68 6c bf 10 80       	push   $0x8010bf6c
80109370:	e8 7f 70 ff ff       	call   801003f4 <cprintf>
80109375:	83 c4 20             	add    $0x20,%esp
}
80109378:	90                   	nop
80109379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010937c:	c9                   	leave
8010937d:	c3                   	ret

8010937e <print_mac>:

void print_mac(uchar *mac){
8010937e:	55                   	push   %ebp
8010937f:	89 e5                	mov    %esp,%ebp
80109381:	57                   	push   %edi
80109382:	56                   	push   %esi
80109383:	53                   	push   %ebx
80109384:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109387:	8b 45 08             	mov    0x8(%ebp),%eax
8010938a:	83 c0 05             	add    $0x5,%eax
8010938d:	0f b6 00             	movzbl (%eax),%eax
80109390:	0f b6 f8             	movzbl %al,%edi
80109393:	8b 45 08             	mov    0x8(%ebp),%eax
80109396:	83 c0 04             	add    $0x4,%eax
80109399:	0f b6 00             	movzbl (%eax),%eax
8010939c:	0f b6 f0             	movzbl %al,%esi
8010939f:	8b 45 08             	mov    0x8(%ebp),%eax
801093a2:	83 c0 03             	add    $0x3,%eax
801093a5:	0f b6 00             	movzbl (%eax),%eax
801093a8:	0f b6 d8             	movzbl %al,%ebx
801093ab:	8b 45 08             	mov    0x8(%ebp),%eax
801093ae:	83 c0 02             	add    $0x2,%eax
801093b1:	0f b6 00             	movzbl (%eax),%eax
801093b4:	0f b6 c8             	movzbl %al,%ecx
801093b7:	8b 45 08             	mov    0x8(%ebp),%eax
801093ba:	83 c0 01             	add    $0x1,%eax
801093bd:	0f b6 00             	movzbl (%eax),%eax
801093c0:	0f b6 d0             	movzbl %al,%edx
801093c3:	8b 45 08             	mov    0x8(%ebp),%eax
801093c6:	0f b6 00             	movzbl (%eax),%eax
801093c9:	0f b6 c0             	movzbl %al,%eax
801093cc:	83 ec 04             	sub    $0x4,%esp
801093cf:	57                   	push   %edi
801093d0:	56                   	push   %esi
801093d1:	53                   	push   %ebx
801093d2:	51                   	push   %ecx
801093d3:	52                   	push   %edx
801093d4:	50                   	push   %eax
801093d5:	68 84 bf 10 80       	push   $0x8010bf84
801093da:	e8 15 70 ff ff       	call   801003f4 <cprintf>
801093df:	83 c4 20             	add    $0x20,%esp
}
801093e2:	90                   	nop
801093e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801093e6:	5b                   	pop    %ebx
801093e7:	5e                   	pop    %esi
801093e8:	5f                   	pop    %edi
801093e9:	5d                   	pop    %ebp
801093ea:	c3                   	ret

801093eb <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801093eb:	55                   	push   %ebp
801093ec:	89 e5                	mov    %esp,%ebp
801093ee:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801093f1:	8b 45 08             	mov    0x8(%ebp),%eax
801093f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801093f7:	8b 45 08             	mov    0x8(%ebp),%eax
801093fa:	83 c0 0e             	add    $0xe,%eax
801093fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
80109400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109403:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80109407:	3c 08                	cmp    $0x8,%al
80109409:	75 1b                	jne    80109426 <eth_proc+0x3b>
8010940b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010940e:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109412:	3c 06                	cmp    $0x6,%al
80109414:	75 10                	jne    80109426 <eth_proc+0x3b>
    arp_proc(pkt_addr);
80109416:	83 ec 0c             	sub    $0xc,%esp
80109419:	ff 75 f0             	push   -0x10(%ebp)
8010941c:	e8 01 f8 ff ff       	call   80108c22 <arp_proc>
80109421:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109424:	eb 24                	jmp    8010944a <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109429:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010942d:	3c 08                	cmp    $0x8,%al
8010942f:	75 19                	jne    8010944a <eth_proc+0x5f>
80109431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109434:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109438:	84 c0                	test   %al,%al
8010943a:	75 0e                	jne    8010944a <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
8010943c:	83 ec 0c             	sub    $0xc,%esp
8010943f:	ff 75 08             	push   0x8(%ebp)
80109442:	e8 8d 00 00 00       	call   801094d4 <ipv4_proc>
80109447:	83 c4 10             	add    $0x10,%esp
}
8010944a:	90                   	nop
8010944b:	c9                   	leave
8010944c:	c3                   	ret

8010944d <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010944d:	55                   	push   %ebp
8010944e:	89 e5                	mov    %esp,%ebp
80109450:	83 ec 04             	sub    $0x4,%esp
80109453:	8b 45 08             	mov    0x8(%ebp),%eax
80109456:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010945a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010945e:	66 c1 c0 08          	rol    $0x8,%ax
}
80109462:	c9                   	leave
80109463:	c3                   	ret

80109464 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109464:	55                   	push   %ebp
80109465:	89 e5                	mov    %esp,%ebp
80109467:	83 ec 04             	sub    $0x4,%esp
8010946a:	8b 45 08             	mov    0x8(%ebp),%eax
8010946d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109471:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109475:	66 c1 c0 08          	rol    $0x8,%ax
}
80109479:	c9                   	leave
8010947a:	c3                   	ret

8010947b <H2N_uint>:

uint H2N_uint(uint value){
8010947b:	55                   	push   %ebp
8010947c:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010947e:	8b 45 08             	mov    0x8(%ebp),%eax
80109481:	c1 e0 18             	shl    $0x18,%eax
80109484:	25 00 00 00 0f       	and    $0xf000000,%eax
80109489:	89 c2                	mov    %eax,%edx
8010948b:	8b 45 08             	mov    0x8(%ebp),%eax
8010948e:	c1 e0 08             	shl    $0x8,%eax
80109491:	25 00 f0 00 00       	and    $0xf000,%eax
80109496:	09 c2                	or     %eax,%edx
80109498:	8b 45 08             	mov    0x8(%ebp),%eax
8010949b:	c1 e8 08             	shr    $0x8,%eax
8010949e:	83 e0 0f             	and    $0xf,%eax
801094a1:	01 d0                	add    %edx,%eax
}
801094a3:	5d                   	pop    %ebp
801094a4:	c3                   	ret

801094a5 <N2H_uint>:

uint N2H_uint(uint value){
801094a5:	55                   	push   %ebp
801094a6:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
801094a8:	8b 45 08             	mov    0x8(%ebp),%eax
801094ab:	c1 e0 18             	shl    $0x18,%eax
801094ae:	89 c2                	mov    %eax,%edx
801094b0:	8b 45 08             	mov    0x8(%ebp),%eax
801094b3:	c1 e0 08             	shl    $0x8,%eax
801094b6:	25 00 00 ff 00       	and    $0xff0000,%eax
801094bb:	01 c2                	add    %eax,%edx
801094bd:	8b 45 08             	mov    0x8(%ebp),%eax
801094c0:	c1 e8 08             	shr    $0x8,%eax
801094c3:	25 00 ff 00 00       	and    $0xff00,%eax
801094c8:	01 c2                	add    %eax,%edx
801094ca:	8b 45 08             	mov    0x8(%ebp),%eax
801094cd:	c1 e8 18             	shr    $0x18,%eax
801094d0:	01 d0                	add    %edx,%eax
}
801094d2:	5d                   	pop    %ebp
801094d3:	c3                   	ret

801094d4 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801094d4:	55                   	push   %ebp
801094d5:	89 e5                	mov    %esp,%ebp
801094d7:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801094da:	8b 45 08             	mov    0x8(%ebp),%eax
801094dd:	83 c0 0e             	add    $0xe,%eax
801094e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801094e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801094ea:	0f b7 d0             	movzwl %ax,%edx
801094ed:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801094f2:	39 c2                	cmp    %eax,%edx
801094f4:	74 60                	je     80109556 <ipv4_proc+0x82>
801094f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f9:	83 c0 0c             	add    $0xc,%eax
801094fc:	83 ec 04             	sub    $0x4,%esp
801094ff:	6a 04                	push   $0x4
80109501:	50                   	push   %eax
80109502:	68 e4 f4 10 80       	push   $0x8010f4e4
80109507:	e8 f6 b4 ff ff       	call   80104a02 <memcmp>
8010950c:	83 c4 10             	add    $0x10,%esp
8010950f:	85 c0                	test   %eax,%eax
80109511:	74 43                	je     80109556 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
80109513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109516:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010951a:	0f b7 c0             	movzwl %ax,%eax
8010951d:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109525:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109529:	3c 01                	cmp    $0x1,%al
8010952b:	75 10                	jne    8010953d <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
8010952d:	83 ec 0c             	sub    $0xc,%esp
80109530:	ff 75 08             	push   0x8(%ebp)
80109533:	e8 a3 00 00 00       	call   801095db <icmp_proc>
80109538:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
8010953b:	eb 19                	jmp    80109556 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
8010953d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109540:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109544:	3c 06                	cmp    $0x6,%al
80109546:	75 0e                	jne    80109556 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109548:	83 ec 0c             	sub    $0xc,%esp
8010954b:	ff 75 08             	push   0x8(%ebp)
8010954e:	e8 b3 03 00 00       	call   80109906 <tcp_proc>
80109553:	83 c4 10             	add    $0x10,%esp
}
80109556:	90                   	nop
80109557:	c9                   	leave
80109558:	c3                   	ret

80109559 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109559:	55                   	push   %ebp
8010955a:	89 e5                	mov    %esp,%ebp
8010955c:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010955f:	8b 45 08             	mov    0x8(%ebp),%eax
80109562:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109568:	0f b6 00             	movzbl (%eax),%eax
8010956b:	83 e0 0f             	and    $0xf,%eax
8010956e:	01 c0                	add    %eax,%eax
80109570:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109573:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010957a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109581:	eb 48                	jmp    801095cb <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109583:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109586:	01 c0                	add    %eax,%eax
80109588:	89 c2                	mov    %eax,%edx
8010958a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010958d:	01 d0                	add    %edx,%eax
8010958f:	0f b6 00             	movzbl (%eax),%eax
80109592:	0f b6 c0             	movzbl %al,%eax
80109595:	c1 e0 08             	shl    $0x8,%eax
80109598:	89 c2                	mov    %eax,%edx
8010959a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010959d:	01 c0                	add    %eax,%eax
8010959f:	8d 48 01             	lea    0x1(%eax),%ecx
801095a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a5:	01 c8                	add    %ecx,%eax
801095a7:	0f b6 00             	movzbl (%eax),%eax
801095aa:	0f b6 c0             	movzbl %al,%eax
801095ad:	01 d0                	add    %edx,%eax
801095af:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801095b2:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801095b9:	76 0c                	jbe    801095c7 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
801095bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801095be:	0f b7 c0             	movzwl %ax,%eax
801095c1:	83 c0 01             	add    $0x1,%eax
801095c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
801095c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801095cb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
801095cf:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801095d2:	7c af                	jl     80109583 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
801095d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801095d7:	f7 d0                	not    %eax
}
801095d9:	c9                   	leave
801095da:	c3                   	ret

801095db <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
801095db:	55                   	push   %ebp
801095dc:	89 e5                	mov    %esp,%ebp
801095de:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801095e1:	8b 45 08             	mov    0x8(%ebp),%eax
801095e4:	83 c0 0e             	add    $0xe,%eax
801095e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801095ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ed:	0f b6 00             	movzbl (%eax),%eax
801095f0:	0f b6 c0             	movzbl %al,%eax
801095f3:	83 e0 0f             	and    $0xf,%eax
801095f6:	c1 e0 02             	shl    $0x2,%eax
801095f9:	89 c2                	mov    %eax,%edx
801095fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095fe:	01 d0                	add    %edx,%eax
80109600:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109603:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109606:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010960a:	84 c0                	test   %al,%al
8010960c:	75 4f                	jne    8010965d <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
8010960e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109611:	0f b6 00             	movzbl (%eax),%eax
80109614:	3c 08                	cmp    $0x8,%al
80109616:	75 45                	jne    8010965d <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109618:	e8 8b 91 ff ff       	call   801027a8 <kalloc>
8010961d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109620:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109627:	83 ec 04             	sub    $0x4,%esp
8010962a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010962d:	50                   	push   %eax
8010962e:	ff 75 ec             	push   -0x14(%ebp)
80109631:	ff 75 08             	push   0x8(%ebp)
80109634:	e8 78 00 00 00       	call   801096b1 <icmp_reply_pkt_create>
80109639:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
8010963c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010963f:	83 ec 08             	sub    $0x8,%esp
80109642:	50                   	push   %eax
80109643:	ff 75 ec             	push   -0x14(%ebp)
80109646:	e8 ad f4 ff ff       	call   80108af8 <i8254_send>
8010964b:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010964e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109651:	83 ec 0c             	sub    $0xc,%esp
80109654:	50                   	push   %eax
80109655:	e8 b4 90 ff ff       	call   8010270e <kfree>
8010965a:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010965d:	90                   	nop
8010965e:	c9                   	leave
8010965f:	c3                   	ret

80109660 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109660:	55                   	push   %ebp
80109661:	89 e5                	mov    %esp,%ebp
80109663:	53                   	push   %ebx
80109664:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109667:	8b 45 08             	mov    0x8(%ebp),%eax
8010966a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010966e:	0f b7 c0             	movzwl %ax,%eax
80109671:	83 ec 0c             	sub    $0xc,%esp
80109674:	50                   	push   %eax
80109675:	e8 d3 fd ff ff       	call   8010944d <N2H_ushort>
8010967a:	83 c4 10             	add    $0x10,%esp
8010967d:	0f b7 d8             	movzwl %ax,%ebx
80109680:	8b 45 08             	mov    0x8(%ebp),%eax
80109683:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109687:	0f b7 c0             	movzwl %ax,%eax
8010968a:	83 ec 0c             	sub    $0xc,%esp
8010968d:	50                   	push   %eax
8010968e:	e8 ba fd ff ff       	call   8010944d <N2H_ushort>
80109693:	83 c4 10             	add    $0x10,%esp
80109696:	0f b7 c0             	movzwl %ax,%eax
80109699:	83 ec 04             	sub    $0x4,%esp
8010969c:	53                   	push   %ebx
8010969d:	50                   	push   %eax
8010969e:	68 a3 bf 10 80       	push   $0x8010bfa3
801096a3:	e8 4c 6d ff ff       	call   801003f4 <cprintf>
801096a8:	83 c4 10             	add    $0x10,%esp
}
801096ab:	90                   	nop
801096ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801096af:	c9                   	leave
801096b0:	c3                   	ret

801096b1 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
801096b1:	55                   	push   %ebp
801096b2:	89 e5                	mov    %esp,%ebp
801096b4:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
801096b7:	8b 45 08             	mov    0x8(%ebp),%eax
801096ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
801096bd:	8b 45 08             	mov    0x8(%ebp),%eax
801096c0:	83 c0 0e             	add    $0xe,%eax
801096c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
801096c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096c9:	0f b6 00             	movzbl (%eax),%eax
801096cc:	0f b6 c0             	movzbl %al,%eax
801096cf:	83 e0 0f             	and    $0xf,%eax
801096d2:	c1 e0 02             	shl    $0x2,%eax
801096d5:	89 c2                	mov    %eax,%edx
801096d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096da:	01 d0                	add    %edx,%eax
801096dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801096df:	8b 45 0c             	mov    0xc(%ebp),%eax
801096e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801096e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801096e8:	83 c0 0e             	add    $0xe,%eax
801096eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801096ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096f1:	83 c0 14             	add    $0x14,%eax
801096f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801096f7:	8b 45 10             	mov    0x10(%ebp),%eax
801096fa:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109703:	8d 50 06             	lea    0x6(%eax),%edx
80109706:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109709:	83 ec 04             	sub    $0x4,%esp
8010970c:	6a 06                	push   $0x6
8010970e:	52                   	push   %edx
8010970f:	50                   	push   %eax
80109710:	e8 45 b3 ff ff       	call   80104a5a <memmove>
80109715:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109718:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010971b:	83 c0 06             	add    $0x6,%eax
8010971e:	83 ec 04             	sub    $0x4,%esp
80109721:	6a 06                	push   $0x6
80109723:	68 80 6d 19 80       	push   $0x80196d80
80109728:	50                   	push   %eax
80109729:	e8 2c b3 ff ff       	call   80104a5a <memmove>
8010972e:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109731:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109734:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109738:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010973b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010973f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109742:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109745:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109748:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010974c:	83 ec 0c             	sub    $0xc,%esp
8010974f:	6a 54                	push   $0x54
80109751:	e8 0e fd ff ff       	call   80109464 <H2N_ushort>
80109756:	83 c4 10             	add    $0x10,%esp
80109759:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010975c:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109760:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010976a:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010976e:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109775:	83 c0 01             	add    $0x1,%eax
80109778:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x4000);
8010977e:	83 ec 0c             	sub    $0xc,%esp
80109781:	68 00 40 00 00       	push   $0x4000
80109786:	e8 d9 fc ff ff       	call   80109464 <H2N_ushort>
8010978b:	83 c4 10             	add    $0x10,%esp
8010978e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109791:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109795:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109798:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010979c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010979f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
801097a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097a6:	83 c0 0c             	add    $0xc,%eax
801097a9:	83 ec 04             	sub    $0x4,%esp
801097ac:	6a 04                	push   $0x4
801097ae:	68 e4 f4 10 80       	push   $0x8010f4e4
801097b3:	50                   	push   %eax
801097b4:	e8 a1 b2 ff ff       	call   80104a5a <memmove>
801097b9:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
801097bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097bf:	8d 50 0c             	lea    0xc(%eax),%edx
801097c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097c5:	83 c0 10             	add    $0x10,%eax
801097c8:	83 ec 04             	sub    $0x4,%esp
801097cb:	6a 04                	push   $0x4
801097cd:	52                   	push   %edx
801097ce:	50                   	push   %eax
801097cf:	e8 86 b2 ff ff       	call   80104a5a <memmove>
801097d4:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
801097d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097da:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
801097e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097e3:	83 ec 0c             	sub    $0xc,%esp
801097e6:	50                   	push   %eax
801097e7:	e8 6d fd ff ff       	call   80109559 <ipv4_chksum>
801097ec:	83 c4 10             	add    $0x10,%esp
801097ef:	0f b7 c0             	movzwl %ax,%eax
801097f2:	83 ec 0c             	sub    $0xc,%esp
801097f5:	50                   	push   %eax
801097f6:	e8 69 fc ff ff       	call   80109464 <H2N_ushort>
801097fb:	83 c4 10             	add    $0x10,%esp
801097fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109801:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109805:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109808:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
8010980b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010980e:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109815:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109819:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010981c:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109820:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109823:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109827:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010982a:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
8010982e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109831:	8d 50 08             	lea    0x8(%eax),%edx
80109834:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109837:	83 c0 08             	add    $0x8,%eax
8010983a:	83 ec 04             	sub    $0x4,%esp
8010983d:	6a 08                	push   $0x8
8010983f:	52                   	push   %edx
80109840:	50                   	push   %eax
80109841:	e8 14 b2 ff ff       	call   80104a5a <memmove>
80109846:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109849:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010984c:	8d 50 10             	lea    0x10(%eax),%edx
8010984f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109852:	83 c0 10             	add    $0x10,%eax
80109855:	83 ec 04             	sub    $0x4,%esp
80109858:	6a 30                	push   $0x30
8010985a:	52                   	push   %edx
8010985b:	50                   	push   %eax
8010985c:	e8 f9 b1 ff ff       	call   80104a5a <memmove>
80109861:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109864:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109867:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010986d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109870:	83 ec 0c             	sub    $0xc,%esp
80109873:	50                   	push   %eax
80109874:	e8 1c 00 00 00       	call   80109895 <icmp_chksum>
80109879:	83 c4 10             	add    $0x10,%esp
8010987c:	0f b7 c0             	movzwl %ax,%eax
8010987f:	83 ec 0c             	sub    $0xc,%esp
80109882:	50                   	push   %eax
80109883:	e8 dc fb ff ff       	call   80109464 <H2N_ushort>
80109888:	83 c4 10             	add    $0x10,%esp
8010988b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010988e:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109892:	90                   	nop
80109893:	c9                   	leave
80109894:	c3                   	ret

80109895 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109895:	55                   	push   %ebp
80109896:	89 e5                	mov    %esp,%ebp
80109898:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010989b:	8b 45 08             	mov    0x8(%ebp),%eax
8010989e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
801098a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
801098a8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801098af:	eb 48                	jmp    801098f9 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
801098b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801098b4:	01 c0                	add    %eax,%eax
801098b6:	89 c2                	mov    %eax,%edx
801098b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098bb:	01 d0                	add    %edx,%eax
801098bd:	0f b6 00             	movzbl (%eax),%eax
801098c0:	0f b6 c0             	movzbl %al,%eax
801098c3:	c1 e0 08             	shl    $0x8,%eax
801098c6:	89 c2                	mov    %eax,%edx
801098c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801098cb:	01 c0                	add    %eax,%eax
801098cd:	8d 48 01             	lea    0x1(%eax),%ecx
801098d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d3:	01 c8                	add    %ecx,%eax
801098d5:	0f b6 00             	movzbl (%eax),%eax
801098d8:	0f b6 c0             	movzbl %al,%eax
801098db:	01 d0                	add    %edx,%eax
801098dd:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801098e0:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801098e7:	76 0c                	jbe    801098f5 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
801098e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098ec:	0f b7 c0             	movzwl %ax,%eax
801098ef:	83 c0 01             	add    $0x1,%eax
801098f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801098f5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801098f9:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801098fd:	7e b2                	jle    801098b1 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801098ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109902:	f7 d0                	not    %eax
}
80109904:	c9                   	leave
80109905:	c3                   	ret

80109906 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109906:	55                   	push   %ebp
80109907:	89 e5                	mov    %esp,%ebp
80109909:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
8010990c:	8b 45 08             	mov    0x8(%ebp),%eax
8010990f:	83 c0 0e             	add    $0xe,%eax
80109912:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109918:	0f b6 00             	movzbl (%eax),%eax
8010991b:	0f b6 c0             	movzbl %al,%eax
8010991e:	83 e0 0f             	and    $0xf,%eax
80109921:	c1 e0 02             	shl    $0x2,%eax
80109924:	89 c2                	mov    %eax,%edx
80109926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109929:	01 d0                	add    %edx,%eax
8010992b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
8010992e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109931:	83 c0 14             	add    $0x14,%eax
80109934:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109937:	e8 6c 8e ff ff       	call   801027a8 <kalloc>
8010993c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
8010993f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109946:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109949:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010994d:	0f b6 c0             	movzbl %al,%eax
80109950:	83 e0 02             	and    $0x2,%eax
80109953:	85 c0                	test   %eax,%eax
80109955:	74 3d                	je     80109994 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109957:	83 ec 0c             	sub    $0xc,%esp
8010995a:	6a 00                	push   $0x0
8010995c:	6a 12                	push   $0x12
8010995e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109961:	50                   	push   %eax
80109962:	ff 75 e8             	push   -0x18(%ebp)
80109965:	ff 75 08             	push   0x8(%ebp)
80109968:	e8 a2 01 00 00       	call   80109b0f <tcp_pkt_create>
8010996d:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109970:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109973:	83 ec 08             	sub    $0x8,%esp
80109976:	50                   	push   %eax
80109977:	ff 75 e8             	push   -0x18(%ebp)
8010997a:	e8 79 f1 ff ff       	call   80108af8 <i8254_send>
8010997f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109982:	a1 64 70 19 80       	mov    0x80197064,%eax
80109987:	83 c0 01             	add    $0x1,%eax
8010998a:	a3 64 70 19 80       	mov    %eax,0x80197064
8010998f:	e9 69 01 00 00       	jmp    80109afd <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109994:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109997:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010999b:	3c 18                	cmp    $0x18,%al
8010999d:	0f 85 10 01 00 00    	jne    80109ab3 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
801099a3:	83 ec 04             	sub    $0x4,%esp
801099a6:	6a 03                	push   $0x3
801099a8:	68 be bf 10 80       	push   $0x8010bfbe
801099ad:	ff 75 ec             	push   -0x14(%ebp)
801099b0:	e8 4d b0 ff ff       	call   80104a02 <memcmp>
801099b5:	83 c4 10             	add    $0x10,%esp
801099b8:	85 c0                	test   %eax,%eax
801099ba:	74 74                	je     80109a30 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
801099bc:	83 ec 0c             	sub    $0xc,%esp
801099bf:	68 c2 bf 10 80       	push   $0x8010bfc2
801099c4:	e8 2b 6a ff ff       	call   801003f4 <cprintf>
801099c9:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
801099cc:	83 ec 0c             	sub    $0xc,%esp
801099cf:	6a 00                	push   $0x0
801099d1:	6a 10                	push   $0x10
801099d3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099d6:	50                   	push   %eax
801099d7:	ff 75 e8             	push   -0x18(%ebp)
801099da:	ff 75 08             	push   0x8(%ebp)
801099dd:	e8 2d 01 00 00       	call   80109b0f <tcp_pkt_create>
801099e2:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
801099e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801099e8:	83 ec 08             	sub    $0x8,%esp
801099eb:	50                   	push   %eax
801099ec:	ff 75 e8             	push   -0x18(%ebp)
801099ef:	e8 04 f1 ff ff       	call   80108af8 <i8254_send>
801099f4:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
801099f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099fa:	83 c0 36             	add    $0x36,%eax
801099fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109a00:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109a03:	50                   	push   %eax
80109a04:	ff 75 e0             	push   -0x20(%ebp)
80109a07:	6a 00                	push   $0x0
80109a09:	6a 00                	push   $0x0
80109a0b:	e8 5a 04 00 00       	call   80109e6a <http_proc>
80109a10:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109a13:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109a16:	83 ec 0c             	sub    $0xc,%esp
80109a19:	50                   	push   %eax
80109a1a:	6a 18                	push   $0x18
80109a1c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a1f:	50                   	push   %eax
80109a20:	ff 75 e8             	push   -0x18(%ebp)
80109a23:	ff 75 08             	push   0x8(%ebp)
80109a26:	e8 e4 00 00 00       	call   80109b0f <tcp_pkt_create>
80109a2b:	83 c4 20             	add    $0x20,%esp
80109a2e:	eb 62                	jmp    80109a92 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109a30:	83 ec 0c             	sub    $0xc,%esp
80109a33:	6a 00                	push   $0x0
80109a35:	6a 10                	push   $0x10
80109a37:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a3a:	50                   	push   %eax
80109a3b:	ff 75 e8             	push   -0x18(%ebp)
80109a3e:	ff 75 08             	push   0x8(%ebp)
80109a41:	e8 c9 00 00 00       	call   80109b0f <tcp_pkt_create>
80109a46:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109a49:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a4c:	83 ec 08             	sub    $0x8,%esp
80109a4f:	50                   	push   %eax
80109a50:	ff 75 e8             	push   -0x18(%ebp)
80109a53:	e8 a0 f0 ff ff       	call   80108af8 <i8254_send>
80109a58:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109a5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a5e:	83 c0 36             	add    $0x36,%eax
80109a61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109a64:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109a67:	50                   	push   %eax
80109a68:	ff 75 e4             	push   -0x1c(%ebp)
80109a6b:	6a 00                	push   $0x0
80109a6d:	6a 00                	push   $0x0
80109a6f:	e8 f6 03 00 00       	call   80109e6a <http_proc>
80109a74:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109a77:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109a7a:	83 ec 0c             	sub    $0xc,%esp
80109a7d:	50                   	push   %eax
80109a7e:	6a 18                	push   $0x18
80109a80:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a83:	50                   	push   %eax
80109a84:	ff 75 e8             	push   -0x18(%ebp)
80109a87:	ff 75 08             	push   0x8(%ebp)
80109a8a:	e8 80 00 00 00       	call   80109b0f <tcp_pkt_create>
80109a8f:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109a92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a95:	83 ec 08             	sub    $0x8,%esp
80109a98:	50                   	push   %eax
80109a99:	ff 75 e8             	push   -0x18(%ebp)
80109a9c:	e8 57 f0 ff ff       	call   80108af8 <i8254_send>
80109aa1:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109aa4:	a1 64 70 19 80       	mov    0x80197064,%eax
80109aa9:	83 c0 01             	add    $0x1,%eax
80109aac:	a3 64 70 19 80       	mov    %eax,0x80197064
80109ab1:	eb 4a                	jmp    80109afd <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ab6:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109aba:	3c 10                	cmp    $0x10,%al
80109abc:	75 3f                	jne    80109afd <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109abe:	a1 68 70 19 80       	mov    0x80197068,%eax
80109ac3:	83 f8 01             	cmp    $0x1,%eax
80109ac6:	75 35                	jne    80109afd <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109ac8:	83 ec 0c             	sub    $0xc,%esp
80109acb:	6a 00                	push   $0x0
80109acd:	6a 01                	push   $0x1
80109acf:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109ad2:	50                   	push   %eax
80109ad3:	ff 75 e8             	push   -0x18(%ebp)
80109ad6:	ff 75 08             	push   0x8(%ebp)
80109ad9:	e8 31 00 00 00       	call   80109b0f <tcp_pkt_create>
80109ade:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109ae1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ae4:	83 ec 08             	sub    $0x8,%esp
80109ae7:	50                   	push   %eax
80109ae8:	ff 75 e8             	push   -0x18(%ebp)
80109aeb:	e8 08 f0 ff ff       	call   80108af8 <i8254_send>
80109af0:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109af3:	c7 05 68 70 19 80 00 	movl   $0x0,0x80197068
80109afa:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109afd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b00:	83 ec 0c             	sub    $0xc,%esp
80109b03:	50                   	push   %eax
80109b04:	e8 05 8c ff ff       	call   8010270e <kfree>
80109b09:	83 c4 10             	add    $0x10,%esp
}
80109b0c:	90                   	nop
80109b0d:	c9                   	leave
80109b0e:	c3                   	ret

80109b0f <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109b0f:	55                   	push   %ebp
80109b10:	89 e5                	mov    %esp,%ebp
80109b12:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b15:	8b 45 08             	mov    0x8(%ebp),%eax
80109b18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80109b1e:	83 c0 0e             	add    $0xe,%eax
80109b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b27:	0f b6 00             	movzbl (%eax),%eax
80109b2a:	0f b6 c0             	movzbl %al,%eax
80109b2d:	83 e0 0f             	and    $0xf,%eax
80109b30:	c1 e0 02             	shl    $0x2,%eax
80109b33:	89 c2                	mov    %eax,%edx
80109b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b38:	01 d0                	add    %edx,%eax
80109b3a:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b40:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109b43:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b46:	83 c0 0e             	add    $0xe,%eax
80109b49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109b4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b4f:	83 c0 14             	add    $0x14,%eax
80109b52:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109b55:	8b 45 18             	mov    0x18(%ebp),%eax
80109b58:	8d 50 36             	lea    0x36(%eax),%edx
80109b5b:	8b 45 10             	mov    0x10(%ebp),%eax
80109b5e:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b63:	8d 50 06             	lea    0x6(%eax),%edx
80109b66:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b69:	83 ec 04             	sub    $0x4,%esp
80109b6c:	6a 06                	push   $0x6
80109b6e:	52                   	push   %edx
80109b6f:	50                   	push   %eax
80109b70:	e8 e5 ae ff ff       	call   80104a5a <memmove>
80109b75:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b7b:	83 c0 06             	add    $0x6,%eax
80109b7e:	83 ec 04             	sub    $0x4,%esp
80109b81:	6a 06                	push   $0x6
80109b83:	68 80 6d 19 80       	push   $0x80196d80
80109b88:	50                   	push   %eax
80109b89:	e8 cc ae ff ff       	call   80104a5a <memmove>
80109b8e:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b94:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b9b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ba2:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109ba5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ba8:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109bac:	8b 45 18             	mov    0x18(%ebp),%eax
80109baf:	83 c0 28             	add    $0x28,%eax
80109bb2:	0f b7 c0             	movzwl %ax,%eax
80109bb5:	83 ec 0c             	sub    $0xc,%esp
80109bb8:	50                   	push   %eax
80109bb9:	e8 a6 f8 ff ff       	call   80109464 <H2N_ushort>
80109bbe:	83 c4 10             	add    $0x10,%esp
80109bc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bc4:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109bc8:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109bcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd2:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109bd6:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109bdd:	83 c0 01             	add    $0x1,%eax
80109be0:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x0000);
80109be6:	83 ec 0c             	sub    $0xc,%esp
80109be9:	6a 00                	push   $0x0
80109beb:	e8 74 f8 ff ff       	call   80109464 <H2N_ushort>
80109bf0:	83 c4 10             	add    $0x10,%esp
80109bf3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bf6:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109bfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bfd:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109c01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c04:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c0b:	83 c0 0c             	add    $0xc,%eax
80109c0e:	83 ec 04             	sub    $0x4,%esp
80109c11:	6a 04                	push   $0x4
80109c13:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c18:	50                   	push   %eax
80109c19:	e8 3c ae ff ff       	call   80104a5a <memmove>
80109c1e:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109c24:	8d 50 0c             	lea    0xc(%eax),%edx
80109c27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2a:	83 c0 10             	add    $0x10,%eax
80109c2d:	83 ec 04             	sub    $0x4,%esp
80109c30:	6a 04                	push   $0x4
80109c32:	52                   	push   %edx
80109c33:	50                   	push   %eax
80109c34:	e8 21 ae ff ff       	call   80104a5a <memmove>
80109c39:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c3f:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c48:	83 ec 0c             	sub    $0xc,%esp
80109c4b:	50                   	push   %eax
80109c4c:	e8 08 f9 ff ff       	call   80109559 <ipv4_chksum>
80109c51:	83 c4 10             	add    $0x10,%esp
80109c54:	0f b7 c0             	movzwl %ax,%eax
80109c57:	83 ec 0c             	sub    $0xc,%esp
80109c5a:	50                   	push   %eax
80109c5b:	e8 04 f8 ff ff       	call   80109464 <H2N_ushort>
80109c60:	83 c4 10             	add    $0x10,%esp
80109c63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c66:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c6d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c74:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c7a:	0f b7 10             	movzwl (%eax),%edx
80109c7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c80:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109c84:	a1 64 70 19 80       	mov    0x80197064,%eax
80109c89:	83 ec 0c             	sub    $0xc,%esp
80109c8c:	50                   	push   %eax
80109c8d:	e8 e9 f7 ff ff       	call   8010947b <H2N_uint>
80109c92:	83 c4 10             	add    $0x10,%esp
80109c95:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c98:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109c9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c9e:	8b 40 04             	mov    0x4(%eax),%eax
80109ca1:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109caa:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109cad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cb0:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109cb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cb7:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109cbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cbe:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109cc2:	8b 45 14             	mov    0x14(%ebp),%eax
80109cc5:	89 c2                	mov    %eax,%edx
80109cc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cca:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109ccd:	83 ec 0c             	sub    $0xc,%esp
80109cd0:	68 90 38 00 00       	push   $0x3890
80109cd5:	e8 8a f7 ff ff       	call   80109464 <H2N_ushort>
80109cda:	83 c4 10             	add    $0x10,%esp
80109cdd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ce0:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109ce4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ce7:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cf0:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109cf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cf9:	83 ec 0c             	sub    $0xc,%esp
80109cfc:	50                   	push   %eax
80109cfd:	e8 1f 00 00 00       	call   80109d21 <tcp_chksum>
80109d02:	83 c4 10             	add    $0x10,%esp
80109d05:	83 c0 08             	add    $0x8,%eax
80109d08:	0f b7 c0             	movzwl %ax,%eax
80109d0b:	83 ec 0c             	sub    $0xc,%esp
80109d0e:	50                   	push   %eax
80109d0f:	e8 50 f7 ff ff       	call   80109464 <H2N_ushort>
80109d14:	83 c4 10             	add    $0x10,%esp
80109d17:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d1a:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109d1e:	90                   	nop
80109d1f:	c9                   	leave
80109d20:	c3                   	ret

80109d21 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109d21:	55                   	push   %ebp
80109d22:	89 e5                	mov    %esp,%ebp
80109d24:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109d27:	8b 45 08             	mov    0x8(%ebp),%eax
80109d2a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109d2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d30:	83 c0 14             	add    $0x14,%eax
80109d33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109d36:	83 ec 04             	sub    $0x4,%esp
80109d39:	6a 04                	push   $0x4
80109d3b:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d40:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d43:	50                   	push   %eax
80109d44:	e8 11 ad ff ff       	call   80104a5a <memmove>
80109d49:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109d4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d4f:	83 c0 0c             	add    $0xc,%eax
80109d52:	83 ec 04             	sub    $0x4,%esp
80109d55:	6a 04                	push   $0x4
80109d57:	50                   	push   %eax
80109d58:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d5b:	83 c0 04             	add    $0x4,%eax
80109d5e:	50                   	push   %eax
80109d5f:	e8 f6 ac ff ff       	call   80104a5a <memmove>
80109d64:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109d67:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109d6b:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109d6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d72:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109d76:	0f b7 c0             	movzwl %ax,%eax
80109d79:	83 ec 0c             	sub    $0xc,%esp
80109d7c:	50                   	push   %eax
80109d7d:	e8 cb f6 ff ff       	call   8010944d <N2H_ushort>
80109d82:	83 c4 10             	add    $0x10,%esp
80109d85:	83 e8 14             	sub    $0x14,%eax
80109d88:	0f b7 c0             	movzwl %ax,%eax
80109d8b:	83 ec 0c             	sub    $0xc,%esp
80109d8e:	50                   	push   %eax
80109d8f:	e8 d0 f6 ff ff       	call   80109464 <H2N_ushort>
80109d94:	83 c4 10             	add    $0x10,%esp
80109d97:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109d9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109da2:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109da5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109da8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109daf:	eb 33                	jmp    80109de4 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109db4:	01 c0                	add    %eax,%eax
80109db6:	89 c2                	mov    %eax,%edx
80109db8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dbb:	01 d0                	add    %edx,%eax
80109dbd:	0f b6 00             	movzbl (%eax),%eax
80109dc0:	0f b6 c0             	movzbl %al,%eax
80109dc3:	c1 e0 08             	shl    $0x8,%eax
80109dc6:	89 c2                	mov    %eax,%edx
80109dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109dcb:	01 c0                	add    %eax,%eax
80109dcd:	8d 48 01             	lea    0x1(%eax),%ecx
80109dd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dd3:	01 c8                	add    %ecx,%eax
80109dd5:	0f b6 00             	movzbl (%eax),%eax
80109dd8:	0f b6 c0             	movzbl %al,%eax
80109ddb:	01 d0                	add    %edx,%eax
80109ddd:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109de0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109de4:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109de8:	7e c7                	jle    80109db1 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ded:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109df0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109df7:	eb 33                	jmp    80109e2c <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109df9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dfc:	01 c0                	add    %eax,%eax
80109dfe:	89 c2                	mov    %eax,%edx
80109e00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e03:	01 d0                	add    %edx,%eax
80109e05:	0f b6 00             	movzbl (%eax),%eax
80109e08:	0f b6 c0             	movzbl %al,%eax
80109e0b:	c1 e0 08             	shl    $0x8,%eax
80109e0e:	89 c2                	mov    %eax,%edx
80109e10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109e13:	01 c0                	add    %eax,%eax
80109e15:	8d 48 01             	lea    0x1(%eax),%ecx
80109e18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e1b:	01 c8                	add    %ecx,%eax
80109e1d:	0f b6 00             	movzbl (%eax),%eax
80109e20:	0f b6 c0             	movzbl %al,%eax
80109e23:	01 d0                	add    %edx,%eax
80109e25:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109e28:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109e2c:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109e30:	0f b7 c0             	movzwl %ax,%eax
80109e33:	83 ec 0c             	sub    $0xc,%esp
80109e36:	50                   	push   %eax
80109e37:	e8 11 f6 ff ff       	call   8010944d <N2H_ushort>
80109e3c:	83 c4 10             	add    $0x10,%esp
80109e3f:	66 d1 e8             	shr    $1,%ax
80109e42:	0f b7 c0             	movzwl %ax,%eax
80109e45:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109e48:	7c af                	jl     80109df9 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e4d:	c1 e8 10             	shr    $0x10,%eax
80109e50:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e56:	f7 d0                	not    %eax
}
80109e58:	c9                   	leave
80109e59:	c3                   	ret

80109e5a <tcp_fin>:

void tcp_fin(){
80109e5a:	55                   	push   %ebp
80109e5b:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109e5d:	c7 05 68 70 19 80 01 	movl   $0x1,0x80197068
80109e64:	00 00 00 
}
80109e67:	90                   	nop
80109e68:	5d                   	pop    %ebp
80109e69:	c3                   	ret

80109e6a <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109e6a:	55                   	push   %ebp
80109e6b:	89 e5                	mov    %esp,%ebp
80109e6d:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109e70:	8b 45 10             	mov    0x10(%ebp),%eax
80109e73:	83 ec 04             	sub    $0x4,%esp
80109e76:	6a 00                	push   $0x0
80109e78:	68 cb bf 10 80       	push   $0x8010bfcb
80109e7d:	50                   	push   %eax
80109e7e:	e8 65 00 00 00       	call   80109ee8 <http_strcpy>
80109e83:	83 c4 10             	add    $0x10,%esp
80109e86:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109e89:	8b 45 10             	mov    0x10(%ebp),%eax
80109e8c:	83 ec 04             	sub    $0x4,%esp
80109e8f:	ff 75 f4             	push   -0xc(%ebp)
80109e92:	68 de bf 10 80       	push   $0x8010bfde
80109e97:	50                   	push   %eax
80109e98:	e8 4b 00 00 00       	call   80109ee8 <http_strcpy>
80109e9d:	83 c4 10             	add    $0x10,%esp
80109ea0:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109ea3:	8b 45 10             	mov    0x10(%ebp),%eax
80109ea6:	83 ec 04             	sub    $0x4,%esp
80109ea9:	ff 75 f4             	push   -0xc(%ebp)
80109eac:	68 f9 bf 10 80       	push   $0x8010bff9
80109eb1:	50                   	push   %eax
80109eb2:	e8 31 00 00 00       	call   80109ee8 <http_strcpy>
80109eb7:	83 c4 10             	add    $0x10,%esp
80109eba:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ec0:	83 e0 01             	and    $0x1,%eax
80109ec3:	85 c0                	test   %eax,%eax
80109ec5:	74 11                	je     80109ed8 <http_proc+0x6e>
    char *payload = (char *)send;
80109ec7:	8b 45 10             	mov    0x10(%ebp),%eax
80109eca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109ecd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109ed0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ed3:	01 d0                	add    %edx,%eax
80109ed5:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109edb:	8b 45 14             	mov    0x14(%ebp),%eax
80109ede:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109ee0:	e8 75 ff ff ff       	call   80109e5a <tcp_fin>
}
80109ee5:	90                   	nop
80109ee6:	c9                   	leave
80109ee7:	c3                   	ret

80109ee8 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109ee8:	55                   	push   %ebp
80109ee9:	89 e5                	mov    %esp,%ebp
80109eeb:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109eee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109ef5:	eb 20                	jmp    80109f17 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109ef7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109efa:	8b 45 0c             	mov    0xc(%ebp),%eax
80109efd:	01 d0                	add    %edx,%eax
80109eff:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109f02:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109f05:	01 ca                	add    %ecx,%edx
80109f07:	89 d1                	mov    %edx,%ecx
80109f09:	8b 55 08             	mov    0x8(%ebp),%edx
80109f0c:	01 ca                	add    %ecx,%edx
80109f0e:	0f b6 00             	movzbl (%eax),%eax
80109f11:	88 02                	mov    %al,(%edx)
    i++;
80109f13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109f17:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f1d:	01 d0                	add    %edx,%eax
80109f1f:	0f b6 00             	movzbl (%eax),%eax
80109f22:	84 c0                	test   %al,%al
80109f24:	75 d1                	jne    80109ef7 <http_strcpy+0xf>
  }
  return i;
80109f26:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109f29:	c9                   	leave
80109f2a:	c3                   	ret

80109f2b <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109f2b:	55                   	push   %ebp
80109f2c:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109f2e:	c7 05 70 70 19 80 a2 	movl   $0x8010f5a2,0x80197070
80109f35:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109f38:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109f3d:	c1 e8 09             	shr    $0x9,%eax
80109f40:	a3 6c 70 19 80       	mov    %eax,0x8019706c
}
80109f45:	90                   	nop
80109f46:	5d                   	pop    %ebp
80109f47:	c3                   	ret

80109f48 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109f48:	55                   	push   %ebp
80109f49:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109f4b:	90                   	nop
80109f4c:	5d                   	pop    %ebp
80109f4d:	c3                   	ret

80109f4e <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109f4e:	55                   	push   %ebp
80109f4f:	89 e5                	mov    %esp,%ebp
80109f51:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
80109f54:	8b 45 08             	mov    0x8(%ebp),%eax
80109f57:	83 c0 0c             	add    $0xc,%eax
80109f5a:	83 ec 0c             	sub    $0xc,%esp
80109f5d:	50                   	push   %eax
80109f5e:	e8 31 a7 ff ff       	call   80104694 <holdingsleep>
80109f63:	83 c4 10             	add    $0x10,%esp
80109f66:	85 c0                	test   %eax,%eax
80109f68:	75 0d                	jne    80109f77 <iderw+0x29>
    panic("iderw: buf not locked");
80109f6a:	83 ec 0c             	sub    $0xc,%esp
80109f6d:	68 0a c0 10 80       	push   $0x8010c00a
80109f72:	e8 32 66 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80109f77:	8b 45 08             	mov    0x8(%ebp),%eax
80109f7a:	8b 00                	mov    (%eax),%eax
80109f7c:	83 e0 06             	and    $0x6,%eax
80109f7f:	83 f8 02             	cmp    $0x2,%eax
80109f82:	75 0d                	jne    80109f91 <iderw+0x43>
    panic("iderw: nothing to do");
80109f84:	83 ec 0c             	sub    $0xc,%esp
80109f87:	68 20 c0 10 80       	push   $0x8010c020
80109f8c:	e8 18 66 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
80109f91:	8b 45 08             	mov    0x8(%ebp),%eax
80109f94:	8b 40 04             	mov    0x4(%eax),%eax
80109f97:	83 f8 01             	cmp    $0x1,%eax
80109f9a:	74 0d                	je     80109fa9 <iderw+0x5b>
    panic("iderw: request not for disk 1");
80109f9c:	83 ec 0c             	sub    $0xc,%esp
80109f9f:	68 35 c0 10 80       	push   $0x8010c035
80109fa4:	e8 00 66 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
80109fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80109fac:	8b 40 08             	mov    0x8(%eax),%eax
80109faf:	8b 15 6c 70 19 80    	mov    0x8019706c,%edx
80109fb5:	39 d0                	cmp    %edx,%eax
80109fb7:	72 0d                	jb     80109fc6 <iderw+0x78>
    panic("iderw: block out of range");
80109fb9:	83 ec 0c             	sub    $0xc,%esp
80109fbc:	68 53 c0 10 80       	push   $0x8010c053
80109fc1:	e8 e3 65 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
80109fc6:	8b 15 70 70 19 80    	mov    0x80197070,%edx
80109fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80109fcf:	8b 40 08             	mov    0x8(%eax),%eax
80109fd2:	c1 e0 09             	shl    $0x9,%eax
80109fd5:	01 d0                	add    %edx,%eax
80109fd7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
80109fda:	8b 45 08             	mov    0x8(%ebp),%eax
80109fdd:	8b 00                	mov    (%eax),%eax
80109fdf:	83 e0 04             	and    $0x4,%eax
80109fe2:	85 c0                	test   %eax,%eax
80109fe4:	74 2b                	je     8010a011 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
80109fe6:	8b 45 08             	mov    0x8(%ebp),%eax
80109fe9:	8b 00                	mov    (%eax),%eax
80109feb:	83 e0 fb             	and    $0xfffffffb,%eax
80109fee:	89 c2                	mov    %eax,%edx
80109ff0:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff3:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
80109ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff8:	83 c0 5c             	add    $0x5c,%eax
80109ffb:	83 ec 04             	sub    $0x4,%esp
80109ffe:	68 00 02 00 00       	push   $0x200
8010a003:	50                   	push   %eax
8010a004:	ff 75 f4             	push   -0xc(%ebp)
8010a007:	e8 4e aa ff ff       	call   80104a5a <memmove>
8010a00c:	83 c4 10             	add    $0x10,%esp
8010a00f:	eb 1a                	jmp    8010a02b <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a011:	8b 45 08             	mov    0x8(%ebp),%eax
8010a014:	83 c0 5c             	add    $0x5c,%eax
8010a017:	83 ec 04             	sub    $0x4,%esp
8010a01a:	68 00 02 00 00       	push   $0x200
8010a01f:	ff 75 f4             	push   -0xc(%ebp)
8010a022:	50                   	push   %eax
8010a023:	e8 32 aa ff ff       	call   80104a5a <memmove>
8010a028:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a02b:	8b 45 08             	mov    0x8(%ebp),%eax
8010a02e:	8b 00                	mov    (%eax),%eax
8010a030:	83 c8 02             	or     $0x2,%eax
8010a033:	89 c2                	mov    %eax,%edx
8010a035:	8b 45 08             	mov    0x8(%ebp),%eax
8010a038:	89 10                	mov    %edx,(%eax)
}
8010a03a:	90                   	nop
8010a03b:	c9                   	leave
8010a03c:	c3                   	ret
