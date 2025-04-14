
kernel:     file format elf32-i386


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
8010005a:	bc b0 b0 11 80       	mov    $0x8011b0b0,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 49 38 10 80       	mov    $0x80103849,%edx
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
8010006f:	68 20 a4 10 80       	push   $0x8010a420
80100074:	68 00 00 11 80       	push   $0x80110000
80100079:	e8 67 4b 00 00       	call   80104be5 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 47 11 80 fc 	movl   $0x801146fc,0x8011474c
80100088:	46 11 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 47 11 80 fc 	movl   $0x801146fc,0x80114750
80100092:	46 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 00 11 80 	movl   $0x80110034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 47 11 80    	mov    0x80114750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 27 a4 10 80       	push   $0x8010a427
801000c2:	50                   	push   %eax
801000c3:	e8 c0 49 00 00       	call   80104a88 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 47 11 80       	mov    0x80114750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 47 11 80       	mov    %eax,0x80114750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 46 11 80       	mov    $0x801146fc,%eax
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
801000fc:	68 00 00 11 80       	push   $0x80110000
80100101:	e8 01 4b 00 00       	call   80104c07 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 47 11 80       	mov    0x80114750,%eax
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
8010013b:	68 00 00 11 80       	push   $0x80110000
80100140:	e8 30 4b 00 00       	call   80104c75 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 6d 49 00 00       	call   80104ac4 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 47 11 80       	mov    0x8011474c,%eax
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
801001bc:	68 00 00 11 80       	push   $0x80110000
801001c1:	e8 af 4a 00 00       	call   80104c75 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 ec 48 00 00       	call   80104ac4 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 46 11 80 	cmpl   $0x801146fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 2e a4 10 80       	push   $0x8010a42e
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
8010022d:	e8 ff 26 00 00       	call   80102931 <iderw>
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
8010024a:	e8 27 49 00 00       	call   80104b76 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f a4 10 80       	push   $0x8010a43f
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
80100278:	e8 b4 26 00 00       	call   80102931 <iderw>
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
80100293:	e8 de 48 00 00       	call   80104b76 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 a4 10 80       	push   $0x8010a446
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 6d 48 00 00       	call   80104b28 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 00 11 80       	push   $0x80110000
801002c6:	e8 3c 49 00 00       	call   80104c07 <acquire>
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
80100305:	8b 15 50 47 11 80    	mov    0x80114750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 46 11 80 	movl   $0x801146fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 47 11 80       	mov    0x80114750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 47 11 80       	mov    %eax,0x80114750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 00 11 80       	push   $0x80110000
80100336:	e8 3a 49 00 00       	call   80104c75 <release>
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
801003fa:	a1 34 4a 11 80       	mov    0x80114a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 4a 11 80       	push   $0x80114a00
80100410:	e8 f2 47 00 00       	call   80104c07 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 4d a4 10 80       	push   $0x8010a44d
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
80100510:	c7 45 ec 56 a4 10 80 	movl   $0x8010a456,-0x14(%ebp)
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
80100599:	68 00 4a 11 80       	push   $0x80114a00
8010059e:	e8 d2 46 00 00       	call   80104c75 <release>
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
801005b4:	c7 05 34 4a 11 80 00 	movl   $0x0,0x80114a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 1b 2a 00 00       	call   80102fde <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 5d a4 10 80       	push   $0x8010a45d
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
801005e6:	68 71 a4 10 80       	push   $0x8010a471
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 c4 46 00 00       	call   80104cc7 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 73 a4 10 80       	push   $0x8010a473
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 49 11 80 01 	movl   $0x1,0x801149ec
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
801006a1:	e8 f7 7c 00 00       	call   8010839d <graphic_scroll_up>
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
801006f4:	e8 a4 7c 00 00       	call   8010839d <graphic_scroll_up>
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
80100756:	e8 af 7c 00 00       	call   8010840a <font_render>
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
80100774:	a1 ec 49 11 80       	mov    0x801149ec,%eax
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
80100793:	e8 7e 60 00 00       	call   80106816 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 71 60 00 00       	call   80106816 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 64 60 00 00       	call   80106816 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 54 60 00 00       	call   80106816 <uartputc>
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
801007e6:	68 00 4a 11 80       	push   $0x80114a00
801007eb:	e8 17 44 00 00       	call   80104c07 <acquire>
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
80100838:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 49 11 80       	mov    %eax,0x801149e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1c ff ff ff       	call   8010076e <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
8010085b:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e1 00 00 00    	je     80100949 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c6 00 00 00       	jmp    80100949 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100889:	a1 e4 49 11 80       	mov    0x801149e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b6 00 00 00    	je     8010094c <consoleintr+0x176>
        input.e--;
80100896:	a1 e8 49 11 80       	mov    0x801149e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 49 11 80       	mov    %eax,0x801149e8
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
801008c2:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
801008c8:	a1 e0 49 11 80       	mov    0x801149e0,%eax
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
801008e7:	a1 e8 49 11 80       	mov    0x801149e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 49 11 80    	mov    %edx,0x801149e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 49 11 80    	mov    %dl,-0x7feeb6a0(%eax)
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
8010091b:	8b 15 e8 49 11 80    	mov    0x801149e8,%edx
80100921:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100926:	83 e8 80             	sub    $0xffffff80,%eax
80100929:	39 c2                	cmp    %eax,%edx
8010092b:	75 22                	jne    8010094f <consoleintr+0x179>
          input.w = input.e;
8010092d:	a1 e8 49 11 80       	mov    0x801149e8,%eax
80100932:	a3 e4 49 11 80       	mov    %eax,0x801149e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 49 11 80       	push   $0x801149e0
8010093f:	e8 5e 3f 00 00       	call   801048a2 <wakeup>
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
80100965:	68 00 4a 11 80       	push   $0x80114a00
8010096a:	e8 06 43 00 00       	call   80104c75 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 e0 3f 00 00       	call   8010495d <procdump>
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
8010099d:	68 00 4a 11 80       	push   $0x80114a00
801009a2:	e8 60 42 00 00       	call   80104c07 <acquire>
801009a7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009aa:	e9 ab 00 00 00       	jmp    80100a5a <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009af:	e8 5e 35 00 00       	call   80103f12 <myproc>
801009b4:	8b 40 24             	mov    0x24(%eax),%eax
801009b7:	85 c0                	test   %eax,%eax
801009b9:	74 28                	je     801009e3 <consoleread+0x63>
        release(&cons.lock);
801009bb:	83 ec 0c             	sub    $0xc,%esp
801009be:	68 00 4a 11 80       	push   $0x80114a00
801009c3:	e8 ad 42 00 00       	call   80104c75 <release>
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
801009e6:	68 00 4a 11 80       	push   $0x80114a00
801009eb:	68 e0 49 11 80       	push   $0x801149e0
801009f0:	e8 c6 3d 00 00       	call   801047bb <sleep>
801009f5:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f8:	8b 15 e0 49 11 80    	mov    0x801149e0,%edx
801009fe:	a1 e4 49 11 80       	mov    0x801149e4,%eax
80100a03:	39 c2                	cmp    %eax,%edx
80100a05:	74 a8                	je     801009af <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a07:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a0c:	8d 50 01             	lea    0x1(%eax),%edx
80100a0f:	89 15 e0 49 11 80    	mov    %edx,0x801149e0
80100a15:	83 e0 7f             	and    $0x7f,%eax
80100a18:	0f b6 80 60 49 11 80 	movzbl -0x7feeb6a0(%eax),%eax
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
80100a33:	a1 e0 49 11 80       	mov    0x801149e0,%eax
80100a38:	83 e8 01             	sub    $0x1,%eax
80100a3b:	a3 e0 49 11 80       	mov    %eax,0x801149e0
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
80100a69:	68 00 4a 11 80       	push   $0x80114a00
80100a6e:	e8 02 42 00 00       	call   80104c75 <release>
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
80100aa7:	68 00 4a 11 80       	push   $0x80114a00
80100aac:	e8 56 41 00 00       	call   80104c07 <acquire>
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
80100ae9:	68 00 4a 11 80       	push   $0x80114a00
80100aee:	e8 82 41 00 00       	call   80104c75 <release>
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
80100b0f:	c7 05 ec 49 11 80 00 	movl   $0x0,0x801149ec
80100b16:	00 00 00 
  initlock(&cons.lock, "console");
80100b19:	83 ec 08             	sub    $0x8,%esp
80100b1c:	68 77 a4 10 80       	push   $0x8010a477
80100b21:	68 00 4a 11 80       	push   $0x80114a00
80100b26:	e8 ba 40 00 00       	call   80104be5 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 4a 11 80 90 	movl   $0x80100a90,0x80114a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 4a 11 80 80 	movl   $0x80100980,0x80114a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 7f a4 10 80 	movl   $0x8010a47f,-0xc(%ebp)
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
80100b6e:	c7 05 34 4a 11 80 01 	movl   $0x1,0x80114a34
80100b75:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b78:	83 ec 08             	sub    $0x8,%esp
80100b7b:	6a 00                	push   $0x0
80100b7d:	6a 01                	push   $0x1
80100b7f:	e8 94 1f 00 00       	call   80102b18 <ioapicenable>
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
80100b93:	e8 7a 33 00 00       	call   80103f12 <myproc>
80100b98:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b9b:	e8 80 29 00 00       	call   80103520 <begin_op>

  if((ip = namei(path)) == 0){
80100ba0:	83 ec 0c             	sub    $0xc,%esp
80100ba3:	ff 75 08             	push   0x8(%ebp)
80100ba6:	e8 7a 19 00 00       	call   80102525 <namei>
80100bab:	83 c4 10             	add    $0x10,%esp
80100bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bb1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bb5:	75 1f                	jne    80100bd6 <exec+0x4c>
    end_op();
80100bb7:	e8 f0 29 00 00       	call   801035ac <end_op>
    cprintf("exec: fail\n");
80100bbc:	83 ec 0c             	sub    $0xc,%esp
80100bbf:	68 95 a4 10 80       	push   $0x8010a495
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
80100c1b:	e8 f2 6b 00 00       	call   80107812 <setupkvm>
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
80100cc1:	e8 46 6f 00 00       	call   80107c0c <allocuvm>
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
80100d07:	e8 33 6e 00 00       	call   80107b3f <loaduvm>
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
80100d48:	e8 5f 28 00 00       	call   801035ac <end_op>
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
80100d76:	e8 91 6e 00 00       	call   80107c0c <allocuvm>
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
80100d9a:	e8 cf 70 00 00       	call   80107e6e <clearpteu>
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
80100dd3:	e8 f3 42 00 00       	call   801050cb <strlen>
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
80100e00:	e8 c6 42 00 00       	call   801050cb <strlen>
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
80100e26:	e8 e2 71 00 00       	call   8010800d <copyout>
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
80100ec2:	e8 46 71 00 00       	call   8010800d <copyout>
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
80100f10:	e8 6b 41 00 00       	call   80105080 <safestrcpy>
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
80100f53:	e8 d8 69 00 00       	call   80107930 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 6f 6e 00 00       	call   80107dd5 <freevm>
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
80100fa1:	e8 2f 6e 00 00       	call   80107dd5 <freevm>
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
80100fbd:	e8 ea 25 00 00       	call   801035ac <end_op>
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
80100fd2:	68 a1 a4 10 80       	push   $0x8010a4a1
80100fd7:	68 a0 4a 11 80       	push   $0x80114aa0
80100fdc:	e8 04 3c 00 00       	call   80104be5 <initlock>
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
80100ff0:	68 a0 4a 11 80       	push   $0x80114aa0
80100ff5:	e8 0d 3c 00 00       	call   80104c07 <acquire>
80100ffa:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ffd:	c7 45 f4 d4 4a 11 80 	movl   $0x80114ad4,-0xc(%ebp)
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
8010101d:	68 a0 4a 11 80       	push   $0x80114aa0
80101022:	e8 4e 3c 00 00       	call   80104c75 <release>
80101027:	83 c4 10             	add    $0x10,%esp
      return f;
8010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102d:	eb 23                	jmp    80101052 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101033:	b8 34 54 11 80       	mov    $0x80115434,%eax
80101038:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103b:	72 c9                	jb     80101006 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 4a 11 80       	push   $0x80114aa0
80101045:	e8 2b 3c 00 00       	call   80104c75 <release>
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
8010105d:	68 a0 4a 11 80       	push   $0x80114aa0
80101062:	e8 a0 3b 00 00       	call   80104c07 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 a8 a4 10 80       	push   $0x8010a4a8
8010107c:	e8 28 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	8d 50 01             	lea    0x1(%eax),%edx
8010108a:	8b 45 08             	mov    0x8(%ebp),%eax
8010108d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 a0 4a 11 80       	push   $0x80114aa0
80101098:	e8 d8 3b 00 00       	call   80104c75 <release>
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
801010ae:	68 a0 4a 11 80       	push   $0x80114aa0
801010b3:	e8 4f 3b 00 00       	call   80104c07 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 b0 a4 10 80       	push   $0x8010a4b0
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
801010ee:	68 a0 4a 11 80       	push   $0x80114aa0
801010f3:	e8 7d 3b 00 00       	call   80104c75 <release>
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
8010113c:	68 a0 4a 11 80       	push   $0x80114aa0
80101141:	e8 2f 3b 00 00       	call   80104c75 <release>
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
80101160:	e8 3c 2a 00 00       	call   80103ba1 <pipeclose>
80101165:	83 c4 10             	add    $0x10,%esp
80101168:	eb 21                	jmp    8010118b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010116d:	83 f8 02             	cmp    $0x2,%eax
80101170:	75 19                	jne    8010118b <fileclose+0xe6>
    begin_op();
80101172:	e8 a9 23 00 00       	call   80103520 <begin_op>
    iput(ff.ip);
80101177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	50                   	push   %eax
8010117e:	e8 d0 09 00 00       	call   80101b53 <iput>
80101183:	83 c4 10             	add    $0x10,%esp
    end_op();
80101186:	e8 21 24 00 00       	call   801035ac <end_op>
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
80101219:	e8 30 2b 00 00       	call   80103d4e <piperead>
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
80101290:	68 ba a4 10 80       	push   $0x8010a4ba
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
801012d2:	e8 75 29 00 00       	call   80103c4c <pipewrite>
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
80101317:	e8 04 22 00 00       	call   80103520 <begin_op>
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
8010137d:	e8 2a 22 00 00       	call   801035ac <end_op>

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
80101393:	68 c3 a4 10 80       	push   $0x8010a4c3
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
801013c9:	68 d3 a4 10 80       	push   $0x8010a4d3
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
80101401:	e8 36 3b 00 00       	call   80104f3c <memmove>
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
80101447:	e8 31 3a 00 00       	call   80104e7d <memset>
8010144c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010144f:	83 ec 0c             	sub    $0xc,%esp
80101452:	ff 75 f4             	push   -0xc(%ebp)
80101455:	e8 ff 22 00 00       	call   80103759 <log_write>
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
8010149a:	a1 58 54 11 80       	mov    0x80115458,%eax
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
80101521:	e8 33 22 00 00       	call   80103759 <log_write>
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
80101570:	a1 40 54 11 80       	mov    0x80115440,%eax
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
80101592:	a1 40 54 11 80       	mov    0x80115440,%eax
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	39 c2                	cmp    %eax,%edx
8010159c:	0f 82 e5 fe ff ff    	jb     80101487 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a2:	83 ec 0c             	sub    $0xc,%esp
801015a5:	68 e0 a4 10 80       	push   $0x8010a4e0
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
801015ba:	68 40 54 11 80       	push   $0x80115440
801015bf:	ff 75 08             	push   0x8(%ebp)
801015c2:	e8 11 fe ff ff       	call   801013d8 <readsb>
801015c7:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cd:	c1 e8 0c             	shr    $0xc,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	a1 58 54 11 80       	mov    0x80115458,%eax
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
80101630:	68 f6 a4 10 80       	push   $0x8010a4f6
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
80101668:	e8 ec 20 00 00       	call   80103759 <log_write>
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
80101694:	68 09 a5 10 80       	push   $0x8010a509
80101699:	68 60 54 11 80       	push   $0x80115460
8010169e:	e8 42 35 00 00       	call   80104be5 <initlock>
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
801016bf:	05 60 54 11 80       	add    $0x80115460,%eax
801016c4:	83 c0 10             	add    $0x10,%eax
801016c7:	83 ec 08             	sub    $0x8,%esp
801016ca:	68 10 a5 10 80       	push   $0x8010a510
801016cf:	50                   	push   %eax
801016d0:	e8 b3 33 00 00       	call   80104a88 <initsleeplock>
801016d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016dc:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e0:	7e cd                	jle    801016af <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	68 40 54 11 80       	push   $0x80115440
801016ea:	ff 75 08             	push   0x8(%ebp)
801016ed:	e8 e6 fc ff ff       	call   801013d8 <readsb>
801016f2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016f5:	a1 58 54 11 80       	mov    0x80115458,%eax
801016fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016fd:	8b 3d 54 54 11 80    	mov    0x80115454,%edi
80101703:	8b 35 50 54 11 80    	mov    0x80115450,%esi
80101709:	8b 1d 4c 54 11 80    	mov    0x8011544c,%ebx
8010170f:	8b 0d 48 54 11 80    	mov    0x80115448,%ecx
80101715:	8b 15 44 54 11 80    	mov    0x80115444,%edx
8010171b:	a1 40 54 11 80       	mov    0x80115440,%eax
80101720:	ff 75 d4             	push   -0x2c(%ebp)
80101723:	57                   	push   %edi
80101724:	56                   	push   %esi
80101725:	53                   	push   %ebx
80101726:	51                   	push   %ecx
80101727:	52                   	push   %edx
80101728:	50                   	push   %eax
80101729:	68 18 a5 10 80       	push   $0x8010a518
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
80101760:	a1 54 54 11 80       	mov    0x80115454,%eax
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
801017a2:	e8 d6 36 00 00       	call   80104e7d <memset>
801017a7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ad:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f0             	push   -0x10(%ebp)
801017ba:	e8 9a 1f 00 00       	call   80103759 <log_write>
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
801017f6:	a1 48 54 11 80       	mov    0x80115448,%eax
801017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 52 ff ff ff    	jb     80101758 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 6b a5 10 80       	push   $0x8010a56b
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
80101826:	a1 54 54 11 80       	mov    0x80115454,%eax
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
801018af:	e8 88 36 00 00       	call   80104f3c <memmove>
801018b4:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	ff 75 f4             	push   -0xc(%ebp)
801018bd:	e8 97 1e 00 00       	call   80103759 <log_write>
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
801018df:	68 60 54 11 80       	push   $0x80115460
801018e4:	e8 1e 33 00 00       	call   80104c07 <acquire>
801018e9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f3:	c7 45 f4 94 54 11 80 	movl   $0x80115494,-0xc(%ebp)
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
8010192d:	68 60 54 11 80       	push   $0x80115460
80101932:	e8 3e 33 00 00       	call   80104c75 <release>
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
8010195c:	81 7d f4 b4 70 11 80 	cmpl   $0x801170b4,-0xc(%ebp)
80101963:	72 97                	jb     801018fc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101965:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101969:	75 0d                	jne    80101978 <iget+0xa2>
    panic("iget: no inodes");
8010196b:	83 ec 0c             	sub    $0xc,%esp
8010196e:	68 7d a5 10 80       	push   $0x8010a57d
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
801019a6:	68 60 54 11 80       	push   $0x80115460
801019ab:	e8 c5 32 00 00       	call   80104c75 <release>
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
801019c1:	68 60 54 11 80       	push   $0x80115460
801019c6:	e8 3c 32 00 00       	call   80104c07 <acquire>
801019cb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 08             	mov    0x8(%eax),%eax
801019d4:	8d 50 01             	lea    0x1(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 60 54 11 80       	push   $0x80115460
801019e5:	e8 8b 32 00 00       	call   80104c75 <release>
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
80101a0b:	68 8d a5 10 80       	push   $0x8010a58d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 a0 30 00 00       	call   80104ac4 <acquiresleep>
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
80101a40:	a1 54 54 11 80       	mov    0x80115454,%eax
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
80101ac9:	e8 6e 34 00 00       	call   80104f3c <memmove>
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
80101af8:	68 93 a5 10 80       	push   $0x8010a593
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
80101b1b:	e8 56 30 00 00       	call   80104b76 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 a2 a5 10 80       	push   $0x8010a5a2
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 db 2f 00 00       	call   80104b28 <releasesleep>
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
80101b63:	e8 5c 2f 00 00       	call   80104ac4 <acquiresleep>
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
80101b84:	68 60 54 11 80       	push   $0x80115460
80101b89:	e8 79 30 00 00       	call   80104c07 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 54 11 80       	push   $0x80115460
80101ba2:	e8 ce 30 00 00       	call   80104c75 <release>
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
80101be9:	e8 3a 2f 00 00       	call   80104b28 <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 54 11 80       	push   $0x80115460
80101bf9:	e8 09 30 00 00       	call   80104c07 <acquire>
80101bfe:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 08             	mov    0x8(%eax),%eax
80101c07:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 60 54 11 80       	push   $0x80115460
80101c18:	e8 58 30 00 00       	call   80104c75 <release>
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
80101d3e:	e8 16 1a 00 00       	call   80103759 <log_write>
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
80101d5c:	68 aa a5 10 80       	push   $0x8010a5aa
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
80101f12:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0a 01 00 00       	jmp    80102031 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2e:	98                   	cwtl
80101f2f:	8b 04 c5 40 4a 11 80 	mov    -0x7feeb5c0(,%eax,8),%eax
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
80101ffa:	e8 3d 2f 00 00       	call   80104f3c <memmove>
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
80102067:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
      return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3b 01 00 00       	jmp    801021b7 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102083:	98                   	cwtl
80102084:	8b 04 c5 44 4a 11 80 	mov    -0x7feeb5bc(,%eax,8),%eax
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
8010214a:	e8 ed 2d 00 00       	call   80104f3c <memmove>
8010214f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	ff 75 f0             	push   -0x10(%ebp)
80102158:	e8 fc 15 00 00       	call   80103759 <log_write>
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
801021ca:	e8 03 2e 00 00       	call   80104fd2 <strncmp>
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
801021ea:	68 bd a5 10 80       	push   $0x8010a5bd
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
80102219:	68 cf a5 10 80       	push   $0x8010a5cf
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
801022ee:	68 de a5 10 80       	push   $0x8010a5de
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
80102329:	e8 fa 2c 00 00       	call   80105028 <strncpy>
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
80102355:	68 eb a5 10 80       	push   $0x8010a5eb
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
801023c7:	e8 70 2b 00 00       	call   80104f3c <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 59 2b 00 00       	call   80104f3c <memmove>
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
8010242d:	e8 e0 1a 00 00       	call   80103f12 <myproc>
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

8010255c <inb>:
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
8010255f:	83 ec 14             	sub    $0x14,%esp
80102562:	8b 45 08             	mov    0x8(%ebp),%eax
80102565:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102569:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010256d:	89 c2                	mov    %eax,%edx
8010256f:	ec                   	in     (%dx),%al
80102570:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102573:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102577:	c9                   	leave
80102578:	c3                   	ret

80102579 <insl>:
{
80102579:	55                   	push   %ebp
8010257a:	89 e5                	mov    %esp,%ebp
8010257c:	57                   	push   %edi
8010257d:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010257e:	8b 55 08             	mov    0x8(%ebp),%edx
80102581:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102584:	8b 45 10             	mov    0x10(%ebp),%eax
80102587:	89 cb                	mov    %ecx,%ebx
80102589:	89 df                	mov    %ebx,%edi
8010258b:	89 c1                	mov    %eax,%ecx
8010258d:	fc                   	cld
8010258e:	f3 6d                	rep insl (%dx),%es:(%edi)
80102590:	89 c8                	mov    %ecx,%eax
80102592:	89 fb                	mov    %edi,%ebx
80102594:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102597:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010259a:	90                   	nop
8010259b:	5b                   	pop    %ebx
8010259c:	5f                   	pop    %edi
8010259d:	5d                   	pop    %ebp
8010259e:	c3                   	ret

8010259f <outb>:
{
8010259f:	55                   	push   %ebp
801025a0:	89 e5                	mov    %esp,%ebp
801025a2:	83 ec 08             	sub    $0x8,%esp
801025a5:	8b 55 08             	mov    0x8(%ebp),%edx
801025a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025ba:	ee                   	out    %al,(%dx)
}
801025bb:	90                   	nop
801025bc:	c9                   	leave
801025bd:	c3                   	ret

801025be <outsl>:
{
801025be:	55                   	push   %ebp
801025bf:	89 e5                	mov    %esp,%ebp
801025c1:	56                   	push   %esi
801025c2:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025c3:	8b 55 08             	mov    0x8(%ebp),%edx
801025c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025c9:	8b 45 10             	mov    0x10(%ebp),%eax
801025cc:	89 cb                	mov    %ecx,%ebx
801025ce:	89 de                	mov    %ebx,%esi
801025d0:	89 c1                	mov    %eax,%ecx
801025d2:	fc                   	cld
801025d3:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025d5:	89 c8                	mov    %ecx,%eax
801025d7:	89 f3                	mov    %esi,%ebx
801025d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025dc:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025df:	90                   	nop
801025e0:	5b                   	pop    %ebx
801025e1:	5e                   	pop    %esi
801025e2:	5d                   	pop    %ebp
801025e3:	c3                   	ret

801025e4 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025e4:	55                   	push   %ebp
801025e5:	89 e5                	mov    %esp,%ebp
801025e7:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025ea:	90                   	nop
801025eb:	68 f7 01 00 00       	push   $0x1f7
801025f0:	e8 67 ff ff ff       	call   8010255c <inb>
801025f5:	83 c4 04             	add    $0x4,%esp
801025f8:	0f b6 c0             	movzbl %al,%eax
801025fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102601:	25 c0 00 00 00       	and    $0xc0,%eax
80102606:	83 f8 40             	cmp    $0x40,%eax
80102609:	75 e0                	jne    801025eb <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010260b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010260f:	74 11                	je     80102622 <idewait+0x3e>
80102611:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102614:	83 e0 21             	and    $0x21,%eax
80102617:	85 c0                	test   %eax,%eax
80102619:	74 07                	je     80102622 <idewait+0x3e>
    return -1;
8010261b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102620:	eb 05                	jmp    80102627 <idewait+0x43>
  return 0;
80102622:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102627:	c9                   	leave
80102628:	c3                   	ret

80102629 <ideinit>:

void
ideinit(void)
{
80102629:	55                   	push   %ebp
8010262a:	89 e5                	mov    %esp,%ebp
8010262c:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
8010262f:	83 ec 08             	sub    $0x8,%esp
80102632:	68 f3 a5 10 80       	push   $0x8010a5f3
80102637:	68 c0 70 11 80       	push   $0x801170c0
8010263c:	e8 a4 25 00 00       	call   80104be5 <initlock>
80102641:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102644:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80102649:	83 e8 01             	sub    $0x1,%eax
8010264c:	83 ec 08             	sub    $0x8,%esp
8010264f:	50                   	push   %eax
80102650:	6a 0e                	push   $0xe
80102652:	e8 c1 04 00 00       	call   80102b18 <ioapicenable>
80102657:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010265a:	83 ec 0c             	sub    $0xc,%esp
8010265d:	6a 00                	push   $0x0
8010265f:	e8 80 ff ff ff       	call   801025e4 <idewait>
80102664:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102667:	83 ec 08             	sub    $0x8,%esp
8010266a:	68 f0 00 00 00       	push   $0xf0
8010266f:	68 f6 01 00 00       	push   $0x1f6
80102674:	e8 26 ff ff ff       	call   8010259f <outb>
80102679:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010267c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102683:	eb 24                	jmp    801026a9 <ideinit+0x80>
    if(inb(0x1f7) != 0){
80102685:	83 ec 0c             	sub    $0xc,%esp
80102688:	68 f7 01 00 00       	push   $0x1f7
8010268d:	e8 ca fe ff ff       	call   8010255c <inb>
80102692:	83 c4 10             	add    $0x10,%esp
80102695:	84 c0                	test   %al,%al
80102697:	74 0c                	je     801026a5 <ideinit+0x7c>
      havedisk1 = 1;
80102699:	c7 05 f8 70 11 80 01 	movl   $0x1,0x801170f8
801026a0:	00 00 00 
      break;
801026a3:	eb 0d                	jmp    801026b2 <ideinit+0x89>
  for(i=0; i<1000; i++){
801026a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026a9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026b0:	7e d3                	jle    80102685 <ideinit+0x5c>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026b2:	83 ec 08             	sub    $0x8,%esp
801026b5:	68 e0 00 00 00       	push   $0xe0
801026ba:	68 f6 01 00 00       	push   $0x1f6
801026bf:	e8 db fe ff ff       	call   8010259f <outb>
801026c4:	83 c4 10             	add    $0x10,%esp
}
801026c7:	90                   	nop
801026c8:	c9                   	leave
801026c9:	c3                   	ret

801026ca <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ca:	55                   	push   %ebp
801026cb:	89 e5                	mov    %esp,%ebp
801026cd:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026d4:	75 0d                	jne    801026e3 <idestart+0x19>
    panic("idestart");
801026d6:	83 ec 0c             	sub    $0xc,%esp
801026d9:	68 f7 a5 10 80       	push   $0x8010a5f7
801026de:	e8 c6 de ff ff       	call   801005a9 <panic>
  if(b->blockno >= FSSIZE)
801026e3:	8b 45 08             	mov    0x8(%ebp),%eax
801026e6:	8b 40 08             	mov    0x8(%eax),%eax
801026e9:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026ee:	76 0d                	jbe    801026fd <idestart+0x33>
    panic("incorrect blockno");
801026f0:	83 ec 0c             	sub    $0xc,%esp
801026f3:	68 00 a6 10 80       	push   $0x8010a600
801026f8:	e8 ac de ff ff       	call   801005a9 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026fd:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102704:	8b 45 08             	mov    0x8(%ebp),%eax
80102707:	8b 50 08             	mov    0x8(%eax),%edx
8010270a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010270d:	0f af c2             	imul   %edx,%eax
80102710:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102713:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102717:	75 07                	jne    80102720 <idestart+0x56>
80102719:	b8 20 00 00 00       	mov    $0x20,%eax
8010271e:	eb 05                	jmp    80102725 <idestart+0x5b>
80102720:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102728:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010272c:	75 07                	jne    80102735 <idestart+0x6b>
8010272e:	b8 30 00 00 00       	mov    $0x30,%eax
80102733:	eb 05                	jmp    8010273a <idestart+0x70>
80102735:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010273a:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010273d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102741:	7e 0d                	jle    80102750 <idestart+0x86>
80102743:	83 ec 0c             	sub    $0xc,%esp
80102746:	68 f7 a5 10 80       	push   $0x8010a5f7
8010274b:	e8 59 de ff ff       	call   801005a9 <panic>

  idewait(0);
80102750:	83 ec 0c             	sub    $0xc,%esp
80102753:	6a 00                	push   $0x0
80102755:	e8 8a fe ff ff       	call   801025e4 <idewait>
8010275a:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
8010275d:	83 ec 08             	sub    $0x8,%esp
80102760:	6a 00                	push   $0x0
80102762:	68 f6 03 00 00       	push   $0x3f6
80102767:	e8 33 fe ff ff       	call   8010259f <outb>
8010276c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010276f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102772:	0f b6 c0             	movzbl %al,%eax
80102775:	83 ec 08             	sub    $0x8,%esp
80102778:	50                   	push   %eax
80102779:	68 f2 01 00 00       	push   $0x1f2
8010277e:	e8 1c fe ff ff       	call   8010259f <outb>
80102783:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102786:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102789:	0f b6 c0             	movzbl %al,%eax
8010278c:	83 ec 08             	sub    $0x8,%esp
8010278f:	50                   	push   %eax
80102790:	68 f3 01 00 00       	push   $0x1f3
80102795:	e8 05 fe ff ff       	call   8010259f <outb>
8010279a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010279d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a0:	c1 f8 08             	sar    $0x8,%eax
801027a3:	0f b6 c0             	movzbl %al,%eax
801027a6:	83 ec 08             	sub    $0x8,%esp
801027a9:	50                   	push   %eax
801027aa:	68 f4 01 00 00       	push   $0x1f4
801027af:	e8 eb fd ff ff       	call   8010259f <outb>
801027b4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ba:	c1 f8 10             	sar    $0x10,%eax
801027bd:	0f b6 c0             	movzbl %al,%eax
801027c0:	83 ec 08             	sub    $0x8,%esp
801027c3:	50                   	push   %eax
801027c4:	68 f5 01 00 00       	push   $0x1f5
801027c9:	e8 d1 fd ff ff       	call   8010259f <outb>
801027ce:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027d1:	8b 45 08             	mov    0x8(%ebp),%eax
801027d4:	8b 40 04             	mov    0x4(%eax),%eax
801027d7:	c1 e0 04             	shl    $0x4,%eax
801027da:	83 e0 10             	and    $0x10,%eax
801027dd:	89 c2                	mov    %eax,%edx
801027df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027e2:	c1 f8 18             	sar    $0x18,%eax
801027e5:	83 e0 0f             	and    $0xf,%eax
801027e8:	09 d0                	or     %edx,%eax
801027ea:	83 c8 e0             	or     $0xffffffe0,%eax
801027ed:	0f b6 c0             	movzbl %al,%eax
801027f0:	83 ec 08             	sub    $0x8,%esp
801027f3:	50                   	push   %eax
801027f4:	68 f6 01 00 00       	push   $0x1f6
801027f9:	e8 a1 fd ff ff       	call   8010259f <outb>
801027fe:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102801:	8b 45 08             	mov    0x8(%ebp),%eax
80102804:	8b 00                	mov    (%eax),%eax
80102806:	83 e0 04             	and    $0x4,%eax
80102809:	85 c0                	test   %eax,%eax
8010280b:	74 35                	je     80102842 <idestart+0x178>
    outb(0x1f7, write_cmd);
8010280d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102810:	0f b6 c0             	movzbl %al,%eax
80102813:	83 ec 08             	sub    $0x8,%esp
80102816:	50                   	push   %eax
80102817:	68 f7 01 00 00       	push   $0x1f7
8010281c:	e8 7e fd ff ff       	call   8010259f <outb>
80102821:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102824:	8b 45 08             	mov    0x8(%ebp),%eax
80102827:	83 c0 5c             	add    $0x5c,%eax
8010282a:	83 ec 04             	sub    $0x4,%esp
8010282d:	68 80 00 00 00       	push   $0x80
80102832:	50                   	push   %eax
80102833:	68 f0 01 00 00       	push   $0x1f0
80102838:	e8 81 fd ff ff       	call   801025be <outsl>
8010283d:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102840:	eb 17                	jmp    80102859 <idestart+0x18f>
    outb(0x1f7, read_cmd);
80102842:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102845:	0f b6 c0             	movzbl %al,%eax
80102848:	83 ec 08             	sub    $0x8,%esp
8010284b:	50                   	push   %eax
8010284c:	68 f7 01 00 00       	push   $0x1f7
80102851:	e8 49 fd ff ff       	call   8010259f <outb>
80102856:	83 c4 10             	add    $0x10,%esp
}
80102859:	90                   	nop
8010285a:	c9                   	leave
8010285b:	c3                   	ret

8010285c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010285c:	55                   	push   %ebp
8010285d:	89 e5                	mov    %esp,%ebp
8010285f:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102862:	83 ec 0c             	sub    $0xc,%esp
80102865:	68 c0 70 11 80       	push   $0x801170c0
8010286a:	e8 98 23 00 00       	call   80104c07 <acquire>
8010286f:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102872:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102877:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010287a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010287e:	75 15                	jne    80102895 <ideintr+0x39>
    release(&idelock);
80102880:	83 ec 0c             	sub    $0xc,%esp
80102883:	68 c0 70 11 80       	push   $0x801170c0
80102888:	e8 e8 23 00 00       	call   80104c75 <release>
8010288d:	83 c4 10             	add    $0x10,%esp
    return;
80102890:	e9 9a 00 00 00       	jmp    8010292f <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102898:	8b 40 58             	mov    0x58(%eax),%eax
8010289b:	a3 f4 70 11 80       	mov    %eax,0x801170f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a3:	8b 00                	mov    (%eax),%eax
801028a5:	83 e0 04             	and    $0x4,%eax
801028a8:	85 c0                	test   %eax,%eax
801028aa:	75 2d                	jne    801028d9 <ideintr+0x7d>
801028ac:	83 ec 0c             	sub    $0xc,%esp
801028af:	6a 01                	push   $0x1
801028b1:	e8 2e fd ff ff       	call   801025e4 <idewait>
801028b6:	83 c4 10             	add    $0x10,%esp
801028b9:	85 c0                	test   %eax,%eax
801028bb:	78 1c                	js     801028d9 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c0:	83 c0 5c             	add    $0x5c,%eax
801028c3:	83 ec 04             	sub    $0x4,%esp
801028c6:	68 80 00 00 00       	push   $0x80
801028cb:	50                   	push   %eax
801028cc:	68 f0 01 00 00       	push   $0x1f0
801028d1:	e8 a3 fc ff ff       	call   80102579 <insl>
801028d6:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028dc:	8b 00                	mov    (%eax),%eax
801028de:	83 c8 02             	or     $0x2,%eax
801028e1:	89 c2                	mov    %eax,%edx
801028e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e6:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028eb:	8b 00                	mov    (%eax),%eax
801028ed:	83 e0 fb             	and    $0xfffffffb,%eax
801028f0:	89 c2                	mov    %eax,%edx
801028f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f5:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028f7:	83 ec 0c             	sub    $0xc,%esp
801028fa:	ff 75 f4             	push   -0xc(%ebp)
801028fd:	e8 a0 1f 00 00       	call   801048a2 <wakeup>
80102902:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102905:	a1 f4 70 11 80       	mov    0x801170f4,%eax
8010290a:	85 c0                	test   %eax,%eax
8010290c:	74 11                	je     8010291f <ideintr+0xc3>
    idestart(idequeue);
8010290e:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80102913:	83 ec 0c             	sub    $0xc,%esp
80102916:	50                   	push   %eax
80102917:	e8 ae fd ff ff       	call   801026ca <idestart>
8010291c:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010291f:	83 ec 0c             	sub    $0xc,%esp
80102922:	68 c0 70 11 80       	push   $0x801170c0
80102927:	e8 49 23 00 00       	call   80104c75 <release>
8010292c:	83 c4 10             	add    $0x10,%esp
}
8010292f:	c9                   	leave
80102930:	c3                   	ret

80102931 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102931:	55                   	push   %ebp
80102932:	89 e5                	mov    %esp,%ebp
80102934:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;
#if IDE_DEBUG
  cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
80102937:	8b 15 f8 70 11 80    	mov    0x801170f8,%edx
8010293d:	8b 45 08             	mov    0x8(%ebp),%eax
80102940:	8b 40 04             	mov    0x4(%eax),%eax
80102943:	83 ec 04             	sub    $0x4,%esp
80102946:	52                   	push   %edx
80102947:	50                   	push   %eax
80102948:	68 12 a6 10 80       	push   $0x8010a612
8010294d:	e8 a2 da ff ff       	call   801003f4 <cprintf>
80102952:	83 c4 10             	add    $0x10,%esp
#endif
  if(!holdingsleep(&b->lock))
80102955:	8b 45 08             	mov    0x8(%ebp),%eax
80102958:	83 c0 0c             	add    $0xc,%eax
8010295b:	83 ec 0c             	sub    $0xc,%esp
8010295e:	50                   	push   %eax
8010295f:	e8 12 22 00 00       	call   80104b76 <holdingsleep>
80102964:	83 c4 10             	add    $0x10,%esp
80102967:	85 c0                	test   %eax,%eax
80102969:	75 0d                	jne    80102978 <iderw+0x47>
    panic("iderw: buf not locked");
8010296b:	83 ec 0c             	sub    $0xc,%esp
8010296e:	68 2c a6 10 80       	push   $0x8010a62c
80102973:	e8 31 dc ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102978:	8b 45 08             	mov    0x8(%ebp),%eax
8010297b:	8b 00                	mov    (%eax),%eax
8010297d:	83 e0 06             	and    $0x6,%eax
80102980:	83 f8 02             	cmp    $0x2,%eax
80102983:	75 0d                	jne    80102992 <iderw+0x61>
    panic("iderw: nothing to do");
80102985:	83 ec 0c             	sub    $0xc,%esp
80102988:	68 42 a6 10 80       	push   $0x8010a642
8010298d:	e8 17 dc ff ff       	call   801005a9 <panic>
  if(b->dev != 0 && !havedisk1)
80102992:	8b 45 08             	mov    0x8(%ebp),%eax
80102995:	8b 40 04             	mov    0x4(%eax),%eax
80102998:	85 c0                	test   %eax,%eax
8010299a:	74 16                	je     801029b2 <iderw+0x81>
8010299c:	a1 f8 70 11 80       	mov    0x801170f8,%eax
801029a1:	85 c0                	test   %eax,%eax
801029a3:	75 0d                	jne    801029b2 <iderw+0x81>
    panic("iderw: ide disk 1 not present");
801029a5:	83 ec 0c             	sub    $0xc,%esp
801029a8:	68 57 a6 10 80       	push   $0x8010a657
801029ad:	e8 f7 db ff ff       	call   801005a9 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029b2:	83 ec 0c             	sub    $0xc,%esp
801029b5:	68 c0 70 11 80       	push   $0x801170c0
801029ba:	e8 48 22 00 00       	call   80104c07 <acquire>
801029bf:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801029c2:	8b 45 08             	mov    0x8(%ebp),%eax
801029c5:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029cc:	c7 45 f4 f4 70 11 80 	movl   $0x801170f4,-0xc(%ebp)
801029d3:	eb 0b                	jmp    801029e0 <iderw+0xaf>
801029d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d8:	8b 00                	mov    (%eax),%eax
801029da:	83 c0 58             	add    $0x58,%eax
801029dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e3:	8b 00                	mov    (%eax),%eax
801029e5:	85 c0                	test   %eax,%eax
801029e7:	75 ec                	jne    801029d5 <iderw+0xa4>
    ;
  *pp = b;
801029e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ec:	8b 55 08             	mov    0x8(%ebp),%edx
801029ef:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029f1:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801029f6:	39 45 08             	cmp    %eax,0x8(%ebp)
801029f9:	75 23                	jne    80102a1e <iderw+0xed>
    idestart(b);
801029fb:	83 ec 0c             	sub    $0xc,%esp
801029fe:	ff 75 08             	push   0x8(%ebp)
80102a01:	e8 c4 fc ff ff       	call   801026ca <idestart>
80102a06:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a09:	eb 13                	jmp    80102a1e <iderw+0xed>
    sleep(b, &idelock);
80102a0b:	83 ec 08             	sub    $0x8,%esp
80102a0e:	68 c0 70 11 80       	push   $0x801170c0
80102a13:	ff 75 08             	push   0x8(%ebp)
80102a16:	e8 a0 1d 00 00       	call   801047bb <sleep>
80102a1b:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a21:	8b 00                	mov    (%eax),%eax
80102a23:	83 e0 06             	and    $0x6,%eax
80102a26:	83 f8 02             	cmp    $0x2,%eax
80102a29:	75 e0                	jne    80102a0b <iderw+0xda>
  }


  release(&idelock);
80102a2b:	83 ec 0c             	sub    $0xc,%esp
80102a2e:	68 c0 70 11 80       	push   $0x801170c0
80102a33:	e8 3d 22 00 00       	call   80104c75 <release>
80102a38:	83 c4 10             	add    $0x10,%esp
}
80102a3b:	90                   	nop
80102a3c:	c9                   	leave
80102a3d:	c3                   	ret

80102a3e <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a3e:	55                   	push   %ebp
80102a3f:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a41:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a46:	8b 55 08             	mov    0x8(%ebp),%edx
80102a49:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a4b:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a50:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a53:	5d                   	pop    %ebp
80102a54:	c3                   	ret

80102a55 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a55:	55                   	push   %ebp
80102a56:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a58:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a5d:	8b 55 08             	mov    0x8(%ebp),%edx
80102a60:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a62:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80102a67:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a6a:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a6d:	90                   	nop
80102a6e:	5d                   	pop    %ebp
80102a6f:	c3                   	ret

80102a70 <ioapicinit>:

void
ioapicinit(void)
{
80102a70:	55                   	push   %ebp
80102a71:	89 e5                	mov    %esp,%ebp
80102a73:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a76:	c7 05 fc 70 11 80 00 	movl   $0xfec00000,0x801170fc
80102a7d:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a80:	6a 01                	push   $0x1
80102a82:	e8 b7 ff ff ff       	call   80102a3e <ioapicread>
80102a87:	83 c4 04             	add    $0x4,%esp
80102a8a:	c1 e8 10             	shr    $0x10,%eax
80102a8d:	25 ff 00 00 00       	and    $0xff,%eax
80102a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a95:	6a 00                	push   $0x0
80102a97:	e8 a2 ff ff ff       	call   80102a3e <ioapicread>
80102a9c:	83 c4 04             	add    $0x4,%esp
80102a9f:	c1 e8 18             	shr    $0x18,%eax
80102aa2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102aa5:	0f b6 05 84 9d 11 80 	movzbl 0x80119d84,%eax
80102aac:	0f b6 c0             	movzbl %al,%eax
80102aaf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102ab2:	74 10                	je     80102ac4 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ab4:	83 ec 0c             	sub    $0xc,%esp
80102ab7:	68 78 a6 10 80       	push   $0x8010a678
80102abc:	e8 33 d9 ff ff       	call   801003f4 <cprintf>
80102ac1:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102acb:	eb 3f                	jmp    80102b0c <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad0:	83 c0 20             	add    $0x20,%eax
80102ad3:	0d 00 00 01 00       	or     $0x10000,%eax
80102ad8:	89 c2                	mov    %eax,%edx
80102ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102add:	83 c0 08             	add    $0x8,%eax
80102ae0:	01 c0                	add    %eax,%eax
80102ae2:	83 ec 08             	sub    $0x8,%esp
80102ae5:	52                   	push   %edx
80102ae6:	50                   	push   %eax
80102ae7:	e8 69 ff ff ff       	call   80102a55 <ioapicwrite>
80102aec:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af2:	83 c0 08             	add    $0x8,%eax
80102af5:	01 c0                	add    %eax,%eax
80102af7:	83 c0 01             	add    $0x1,%eax
80102afa:	83 ec 08             	sub    $0x8,%esp
80102afd:	6a 00                	push   $0x0
80102aff:	50                   	push   %eax
80102b00:	e8 50 ff ff ff       	call   80102a55 <ioapicwrite>
80102b05:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102b08:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b12:	7e b9                	jle    80102acd <ioapicinit+0x5d>
  }
}
80102b14:	90                   	nop
80102b15:	90                   	nop
80102b16:	c9                   	leave
80102b17:	c3                   	ret

80102b18 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b18:	55                   	push   %ebp
80102b19:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1e:	83 c0 20             	add    $0x20,%eax
80102b21:	89 c2                	mov    %eax,%edx
80102b23:	8b 45 08             	mov    0x8(%ebp),%eax
80102b26:	83 c0 08             	add    $0x8,%eax
80102b29:	01 c0                	add    %eax,%eax
80102b2b:	52                   	push   %edx
80102b2c:	50                   	push   %eax
80102b2d:	e8 23 ff ff ff       	call   80102a55 <ioapicwrite>
80102b32:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b35:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b38:	c1 e0 18             	shl    $0x18,%eax
80102b3b:	89 c2                	mov    %eax,%edx
80102b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b40:	83 c0 08             	add    $0x8,%eax
80102b43:	01 c0                	add    %eax,%eax
80102b45:	83 c0 01             	add    $0x1,%eax
80102b48:	52                   	push   %edx
80102b49:	50                   	push   %eax
80102b4a:	e8 06 ff ff ff       	call   80102a55 <ioapicwrite>
80102b4f:	83 c4 08             	add    $0x8,%esp
}
80102b52:	90                   	nop
80102b53:	c9                   	leave
80102b54:	c3                   	ret

80102b55 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b55:	55                   	push   %ebp
80102b56:	89 e5                	mov    %esp,%ebp
80102b58:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b5b:	83 ec 08             	sub    $0x8,%esp
80102b5e:	68 aa a6 10 80       	push   $0x8010a6aa
80102b63:	68 00 71 11 80       	push   $0x80117100
80102b68:	e8 78 20 00 00       	call   80104be5 <initlock>
80102b6d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b70:	c7 05 34 71 11 80 00 	movl   $0x0,0x80117134
80102b77:	00 00 00 
  freerange(vstart, vend);
80102b7a:	83 ec 08             	sub    $0x8,%esp
80102b7d:	ff 75 0c             	push   0xc(%ebp)
80102b80:	ff 75 08             	push   0x8(%ebp)
80102b83:	e8 2a 00 00 00       	call   80102bb2 <freerange>
80102b88:	83 c4 10             	add    $0x10,%esp
}
80102b8b:	90                   	nop
80102b8c:	c9                   	leave
80102b8d:	c3                   	ret

80102b8e <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b8e:	55                   	push   %ebp
80102b8f:	89 e5                	mov    %esp,%ebp
80102b91:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b94:	83 ec 08             	sub    $0x8,%esp
80102b97:	ff 75 0c             	push   0xc(%ebp)
80102b9a:	ff 75 08             	push   0x8(%ebp)
80102b9d:	e8 10 00 00 00       	call   80102bb2 <freerange>
80102ba2:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ba5:	c7 05 34 71 11 80 01 	movl   $0x1,0x80117134
80102bac:	00 00 00 
}
80102baf:	90                   	nop
80102bb0:	c9                   	leave
80102bb1:	c3                   	ret

80102bb2 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bb2:	55                   	push   %ebp
80102bb3:	89 e5                	mov    %esp,%ebp
80102bb5:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbb:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bc0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc8:	eb 15                	jmp    80102bdf <freerange+0x2d>
    kfree(p);
80102bca:	83 ec 0c             	sub    $0xc,%esp
80102bcd:	ff 75 f4             	push   -0xc(%ebp)
80102bd0:	e8 1b 00 00 00       	call   80102bf0 <kfree>
80102bd5:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bd8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be2:	05 00 10 00 00       	add    $0x1000,%eax
80102be7:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bea:	73 de                	jae    80102bca <freerange+0x18>
}
80102bec:	90                   	nop
80102bed:	90                   	nop
80102bee:	c9                   	leave
80102bef:	c3                   	ret

80102bf0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bf0:	55                   	push   %ebp
80102bf1:	89 e5                	mov    %esp,%ebp
80102bf3:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf9:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bfe:	85 c0                	test   %eax,%eax
80102c00:	75 18                	jne    80102c1a <kfree+0x2a>
80102c02:	81 7d 08 00 c0 11 80 	cmpl   $0x8011c000,0x8(%ebp)
80102c09:	72 0f                	jb     80102c1a <kfree+0x2a>
80102c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0e:	05 00 00 00 80       	add    $0x80000000,%eax
80102c13:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102c18:	76 0d                	jbe    80102c27 <kfree+0x37>
    panic("kfree");
80102c1a:	83 ec 0c             	sub    $0xc,%esp
80102c1d:	68 af a6 10 80       	push   $0x8010a6af
80102c22:	e8 82 d9 ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c27:	83 ec 04             	sub    $0x4,%esp
80102c2a:	68 00 10 00 00       	push   $0x1000
80102c2f:	6a 01                	push   $0x1
80102c31:	ff 75 08             	push   0x8(%ebp)
80102c34:	e8 44 22 00 00       	call   80104e7d <memset>
80102c39:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c3c:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c41:	85 c0                	test   %eax,%eax
80102c43:	74 10                	je     80102c55 <kfree+0x65>
    acquire(&kmem.lock);
80102c45:	83 ec 0c             	sub    $0xc,%esp
80102c48:	68 00 71 11 80       	push   $0x80117100
80102c4d:	e8 b5 1f 00 00       	call   80104c07 <acquire>
80102c52:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c55:	8b 45 08             	mov    0x8(%ebp),%eax
80102c58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c5b:	8b 15 38 71 11 80    	mov    0x80117138,%edx
80102c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c64:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c69:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102c6e:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c73:	85 c0                	test   %eax,%eax
80102c75:	74 10                	je     80102c87 <kfree+0x97>
    release(&kmem.lock);
80102c77:	83 ec 0c             	sub    $0xc,%esp
80102c7a:	68 00 71 11 80       	push   $0x80117100
80102c7f:	e8 f1 1f 00 00       	call   80104c75 <release>
80102c84:	83 c4 10             	add    $0x10,%esp
}
80102c87:	90                   	nop
80102c88:	c9                   	leave
80102c89:	c3                   	ret

80102c8a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c8a:	55                   	push   %ebp
80102c8b:	89 e5                	mov    %esp,%ebp
80102c8d:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c90:	a1 34 71 11 80       	mov    0x80117134,%eax
80102c95:	85 c0                	test   %eax,%eax
80102c97:	74 10                	je     80102ca9 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c99:	83 ec 0c             	sub    $0xc,%esp
80102c9c:	68 00 71 11 80       	push   $0x80117100
80102ca1:	e8 61 1f 00 00       	call   80104c07 <acquire>
80102ca6:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca9:	a1 38 71 11 80       	mov    0x80117138,%eax
80102cae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cb5:	74 0a                	je     80102cc1 <kalloc+0x37>
    kmem.freelist = r->next;
80102cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cba:	8b 00                	mov    (%eax),%eax
80102cbc:	a3 38 71 11 80       	mov    %eax,0x80117138
  if(kmem.use_lock)
80102cc1:	a1 34 71 11 80       	mov    0x80117134,%eax
80102cc6:	85 c0                	test   %eax,%eax
80102cc8:	74 10                	je     80102cda <kalloc+0x50>
    release(&kmem.lock);
80102cca:	83 ec 0c             	sub    $0xc,%esp
80102ccd:	68 00 71 11 80       	push   $0x80117100
80102cd2:	e8 9e 1f 00 00       	call   80104c75 <release>
80102cd7:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cdd:	c9                   	leave
80102cde:	c3                   	ret

80102cdf <inb>:
{
80102cdf:	55                   	push   %ebp
80102ce0:	89 e5                	mov    %esp,%ebp
80102ce2:	83 ec 14             	sub    $0x14,%esp
80102ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cf0:	89 c2                	mov    %eax,%edx
80102cf2:	ec                   	in     (%dx),%al
80102cf3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cf6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cfa:	c9                   	leave
80102cfb:	c3                   	ret

80102cfc <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cfc:	55                   	push   %ebp
80102cfd:	89 e5                	mov    %esp,%ebp
80102cff:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d02:	6a 64                	push   $0x64
80102d04:	e8 d6 ff ff ff       	call   80102cdf <inb>
80102d09:	83 c4 04             	add    $0x4,%esp
80102d0c:	0f b6 c0             	movzbl %al,%eax
80102d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d15:	83 e0 01             	and    $0x1,%eax
80102d18:	85 c0                	test   %eax,%eax
80102d1a:	75 0a                	jne    80102d26 <kbdgetc+0x2a>
    return -1;
80102d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d21:	e9 23 01 00 00       	jmp    80102e49 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d26:	6a 60                	push   $0x60
80102d28:	e8 b2 ff ff ff       	call   80102cdf <inb>
80102d2d:	83 c4 04             	add    $0x4,%esp
80102d30:	0f b6 c0             	movzbl %al,%eax
80102d33:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d36:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d3d:	75 17                	jne    80102d56 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d3f:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d44:	83 c8 40             	or     $0x40,%eax
80102d47:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d4c:	b8 00 00 00 00       	mov    $0x0,%eax
80102d51:	e9 f3 00 00 00       	jmp    80102e49 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d56:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d59:	25 80 00 00 00       	and    $0x80,%eax
80102d5e:	85 c0                	test   %eax,%eax
80102d60:	74 45                	je     80102da7 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d62:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d67:	83 e0 40             	and    $0x40,%eax
80102d6a:	85 c0                	test   %eax,%eax
80102d6c:	75 08                	jne    80102d76 <kbdgetc+0x7a>
80102d6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d71:	83 e0 7f             	and    $0x7f,%eax
80102d74:	eb 03                	jmp    80102d79 <kbdgetc+0x7d>
80102d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d79:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7f:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102d84:	0f b6 00             	movzbl (%eax),%eax
80102d87:	83 c8 40             	or     $0x40,%eax
80102d8a:	0f b6 c0             	movzbl %al,%eax
80102d8d:	f7 d0                	not    %eax
80102d8f:	89 c2                	mov    %eax,%edx
80102d91:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102d96:	21 d0                	and    %edx,%eax
80102d98:	a3 3c 71 11 80       	mov    %eax,0x8011713c
    return 0;
80102d9d:	b8 00 00 00 00       	mov    $0x0,%eax
80102da2:	e9 a2 00 00 00       	jmp    80102e49 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102da7:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dac:	83 e0 40             	and    $0x40,%eax
80102daf:	85 c0                	test   %eax,%eax
80102db1:	74 14                	je     80102dc7 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102db3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dba:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dbf:	83 e0 bf             	and    $0xffffffbf,%eax
80102dc2:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  }

  shift |= shiftcode[data];
80102dc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dca:	05 20 d0 10 80       	add    $0x8010d020,%eax
80102dcf:	0f b6 00             	movzbl (%eax),%eax
80102dd2:	0f b6 d0             	movzbl %al,%edx
80102dd5:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102dda:	09 d0                	or     %edx,%eax
80102ddc:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  shift ^= togglecode[data];
80102de1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de4:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102de9:	0f b6 00             	movzbl (%eax),%eax
80102dec:	0f b6 d0             	movzbl %al,%edx
80102def:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102df4:	31 d0                	xor    %edx,%eax
80102df6:	a3 3c 71 11 80       	mov    %eax,0x8011713c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dfb:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e00:	83 e0 03             	and    $0x3,%eax
80102e03:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102e0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0d:	01 d0                	add    %edx,%eax
80102e0f:	0f b6 00             	movzbl (%eax),%eax
80102e12:	0f b6 c0             	movzbl %al,%eax
80102e15:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e18:	a1 3c 71 11 80       	mov    0x8011713c,%eax
80102e1d:	83 e0 08             	and    $0x8,%eax
80102e20:	85 c0                	test   %eax,%eax
80102e22:	74 22                	je     80102e46 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e24:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e28:	76 0c                	jbe    80102e36 <kbdgetc+0x13a>
80102e2a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e2e:	77 06                	ja     80102e36 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e30:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e34:	eb 10                	jmp    80102e46 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e36:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e3a:	76 0a                	jbe    80102e46 <kbdgetc+0x14a>
80102e3c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e40:	77 04                	ja     80102e46 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e42:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e46:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e49:	c9                   	leave
80102e4a:	c3                   	ret

80102e4b <kbdintr>:

void
kbdintr(void)
{
80102e4b:	55                   	push   %ebp
80102e4c:	89 e5                	mov    %esp,%ebp
80102e4e:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e51:	83 ec 0c             	sub    $0xc,%esp
80102e54:	68 fc 2c 10 80       	push   $0x80102cfc
80102e59:	e8 78 d9 ff ff       	call   801007d6 <consoleintr>
80102e5e:	83 c4 10             	add    $0x10,%esp
}
80102e61:	90                   	nop
80102e62:	c9                   	leave
80102e63:	c3                   	ret

80102e64 <inb>:
{
80102e64:	55                   	push   %ebp
80102e65:	89 e5                	mov    %esp,%ebp
80102e67:	83 ec 14             	sub    $0x14,%esp
80102e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e6d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e71:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e75:	89 c2                	mov    %eax,%edx
80102e77:	ec                   	in     (%dx),%al
80102e78:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e7b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e7f:	c9                   	leave
80102e80:	c3                   	ret

80102e81 <outb>:
{
80102e81:	55                   	push   %ebp
80102e82:	89 e5                	mov    %esp,%ebp
80102e84:	83 ec 08             	sub    $0x8,%esp
80102e87:	8b 55 08             	mov    0x8(%ebp),%edx
80102e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e8d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e91:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e94:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e98:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e9c:	ee                   	out    %al,(%dx)
}
80102e9d:	90                   	nop
80102e9e:	c9                   	leave
80102e9f:	c3                   	ret

80102ea0 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102ea0:	55                   	push   %ebp
80102ea1:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ea3:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ea8:	8b 55 08             	mov    0x8(%ebp),%edx
80102eab:	c1 e2 02             	shl    $0x2,%edx
80102eae:	01 c2                	add    %eax,%edx
80102eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb3:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb5:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eba:	83 c0 20             	add    $0x20,%eax
80102ebd:	8b 00                	mov    (%eax),%eax
}
80102ebf:	90                   	nop
80102ec0:	5d                   	pop    %ebp
80102ec1:	c3                   	ret

80102ec2 <lapicinit>:

void
lapicinit(void)
{
80102ec2:	55                   	push   %ebp
80102ec3:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102ec5:	a1 40 71 11 80       	mov    0x80117140,%eax
80102eca:	85 c0                	test   %eax,%eax
80102ecc:	0f 84 09 01 00 00    	je     80102fdb <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ed2:	68 3f 01 00 00       	push   $0x13f
80102ed7:	6a 3c                	push   $0x3c
80102ed9:	e8 c2 ff ff ff       	call   80102ea0 <lapicw>
80102ede:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ee1:	6a 0b                	push   $0xb
80102ee3:	68 f8 00 00 00       	push   $0xf8
80102ee8:	e8 b3 ff ff ff       	call   80102ea0 <lapicw>
80102eed:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ef0:	68 20 00 02 00       	push   $0x20020
80102ef5:	68 c8 00 00 00       	push   $0xc8
80102efa:	e8 a1 ff ff ff       	call   80102ea0 <lapicw>
80102eff:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102f02:	68 80 96 98 00       	push   $0x989680
80102f07:	68 e0 00 00 00       	push   $0xe0
80102f0c:	e8 8f ff ff ff       	call   80102ea0 <lapicw>
80102f11:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f14:	68 00 00 01 00       	push   $0x10000
80102f19:	68 d4 00 00 00       	push   $0xd4
80102f1e:	e8 7d ff ff ff       	call   80102ea0 <lapicw>
80102f23:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f26:	68 00 00 01 00       	push   $0x10000
80102f2b:	68 d8 00 00 00       	push   $0xd8
80102f30:	e8 6b ff ff ff       	call   80102ea0 <lapicw>
80102f35:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f38:	a1 40 71 11 80       	mov    0x80117140,%eax
80102f3d:	83 c0 30             	add    $0x30,%eax
80102f40:	8b 00                	mov    (%eax),%eax
80102f42:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102f47:	85 c0                	test   %eax,%eax
80102f49:	74 12                	je     80102f5d <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102f4b:	68 00 00 01 00       	push   $0x10000
80102f50:	68 d0 00 00 00       	push   $0xd0
80102f55:	e8 46 ff ff ff       	call   80102ea0 <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5d:	6a 33                	push   $0x33
80102f5f:	68 dc 00 00 00       	push   $0xdc
80102f64:	e8 37 ff ff ff       	call   80102ea0 <lapicw>
80102f69:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6c:	6a 00                	push   $0x0
80102f6e:	68 a0 00 00 00       	push   $0xa0
80102f73:	e8 28 ff ff ff       	call   80102ea0 <lapicw>
80102f78:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7b:	6a 00                	push   $0x0
80102f7d:	68 a0 00 00 00       	push   $0xa0
80102f82:	e8 19 ff ff ff       	call   80102ea0 <lapicw>
80102f87:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f8a:	6a 00                	push   $0x0
80102f8c:	6a 2c                	push   $0x2c
80102f8e:	e8 0d ff ff ff       	call   80102ea0 <lapicw>
80102f93:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f96:	6a 00                	push   $0x0
80102f98:	68 c4 00 00 00       	push   $0xc4
80102f9d:	e8 fe fe ff ff       	call   80102ea0 <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa5:	68 00 85 08 00       	push   $0x88500
80102faa:	68 c0 00 00 00       	push   $0xc0
80102faf:	e8 ec fe ff ff       	call   80102ea0 <lapicw>
80102fb4:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb7:	90                   	nop
80102fb8:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fbd:	05 00 03 00 00       	add    $0x300,%eax
80102fc2:	8b 00                	mov    (%eax),%eax
80102fc4:	25 00 10 00 00       	and    $0x1000,%eax
80102fc9:	85 c0                	test   %eax,%eax
80102fcb:	75 eb                	jne    80102fb8 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fcd:	6a 00                	push   $0x0
80102fcf:	6a 20                	push   $0x20
80102fd1:	e8 ca fe ff ff       	call   80102ea0 <lapicw>
80102fd6:	83 c4 08             	add    $0x8,%esp
80102fd9:	eb 01                	jmp    80102fdc <lapicinit+0x11a>
    return;
80102fdb:	90                   	nop
}
80102fdc:	c9                   	leave
80102fdd:	c3                   	ret

80102fde <lapicid>:

int
lapicid(void)
{
80102fde:	55                   	push   %ebp
80102fdf:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102fe1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102fe6:	85 c0                	test   %eax,%eax
80102fe8:	75 07                	jne    80102ff1 <lapicid+0x13>
    return 0;
80102fea:	b8 00 00 00 00       	mov    $0x0,%eax
80102fef:	eb 0d                	jmp    80102ffe <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102ff1:	a1 40 71 11 80       	mov    0x80117140,%eax
80102ff6:	83 c0 20             	add    $0x20,%eax
80102ff9:	8b 00                	mov    (%eax),%eax
80102ffb:	c1 e8 18             	shr    $0x18,%eax
}
80102ffe:	5d                   	pop    %ebp
80102fff:	c3                   	ret

80103000 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103000:	55                   	push   %ebp
80103001:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103003:	a1 40 71 11 80       	mov    0x80117140,%eax
80103008:	85 c0                	test   %eax,%eax
8010300a:	74 0c                	je     80103018 <lapiceoi+0x18>
    lapicw(EOI, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	6a 2c                	push   $0x2c
80103010:	e8 8b fe ff ff       	call   80102ea0 <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp
}
80103018:	90                   	nop
80103019:	c9                   	leave
8010301a:	c3                   	ret

8010301b <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
}
8010301e:	90                   	nop
8010301f:	5d                   	pop    %ebp
80103020:	c3                   	ret

80103021 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103021:	55                   	push   %ebp
80103022:	89 e5                	mov    %esp,%ebp
80103024:	83 ec 14             	sub    $0x14,%esp
80103027:	8b 45 08             	mov    0x8(%ebp),%eax
8010302a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010302d:	6a 0f                	push   $0xf
8010302f:	6a 70                	push   $0x70
80103031:	e8 4b fe ff ff       	call   80102e81 <outb>
80103036:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103039:	6a 0a                	push   $0xa
8010303b:	6a 71                	push   $0x71
8010303d:	e8 3f fe ff ff       	call   80102e81 <outb>
80103042:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103045:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010304c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010304f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103054:	8b 45 0c             	mov    0xc(%ebp),%eax
80103057:	c1 e8 04             	shr    $0x4,%eax
8010305a:	89 c2                	mov    %eax,%edx
8010305c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305f:	83 c0 02             	add    $0x2,%eax
80103062:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103065:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103069:	c1 e0 18             	shl    $0x18,%eax
8010306c:	50                   	push   %eax
8010306d:	68 c4 00 00 00       	push   $0xc4
80103072:	e8 29 fe ff ff       	call   80102ea0 <lapicw>
80103077:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010307a:	68 00 c5 00 00       	push   $0xc500
8010307f:	68 c0 00 00 00       	push   $0xc0
80103084:	e8 17 fe ff ff       	call   80102ea0 <lapicw>
80103089:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010308c:	68 c8 00 00 00       	push   $0xc8
80103091:	e8 85 ff ff ff       	call   8010301b <microdelay>
80103096:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103099:	68 00 85 00 00       	push   $0x8500
8010309e:	68 c0 00 00 00       	push   $0xc0
801030a3:	e8 f8 fd ff ff       	call   80102ea0 <lapicw>
801030a8:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ab:	6a 64                	push   $0x64
801030ad:	e8 69 ff ff ff       	call   8010301b <microdelay>
801030b2:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030bc:	eb 3d                	jmp    801030fb <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030be:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030c2:	c1 e0 18             	shl    $0x18,%eax
801030c5:	50                   	push   %eax
801030c6:	68 c4 00 00 00       	push   $0xc4
801030cb:	e8 d0 fd ff ff       	call   80102ea0 <lapicw>
801030d0:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801030d6:	c1 e8 0c             	shr    $0xc,%eax
801030d9:	80 cc 06             	or     $0x6,%ah
801030dc:	50                   	push   %eax
801030dd:	68 c0 00 00 00       	push   $0xc0
801030e2:	e8 b9 fd ff ff       	call   80102ea0 <lapicw>
801030e7:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030ea:	68 c8 00 00 00       	push   $0xc8
801030ef:	e8 27 ff ff ff       	call   8010301b <microdelay>
801030f4:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801030f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030fb:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030ff:	7e bd                	jle    801030be <lapicstartap+0x9d>
  }
}
80103101:	90                   	nop
80103102:	90                   	nop
80103103:	c9                   	leave
80103104:	c3                   	ret

80103105 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103108:	8b 45 08             	mov    0x8(%ebp),%eax
8010310b:	0f b6 c0             	movzbl %al,%eax
8010310e:	50                   	push   %eax
8010310f:	6a 70                	push   $0x70
80103111:	e8 6b fd ff ff       	call   80102e81 <outb>
80103116:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103119:	68 c8 00 00 00       	push   $0xc8
8010311e:	e8 f8 fe ff ff       	call   8010301b <microdelay>
80103123:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103126:	6a 71                	push   $0x71
80103128:	e8 37 fd ff ff       	call   80102e64 <inb>
8010312d:	83 c4 04             	add    $0x4,%esp
80103130:	0f b6 c0             	movzbl %al,%eax
}
80103133:	c9                   	leave
80103134:	c3                   	ret

80103135 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103135:	55                   	push   %ebp
80103136:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103138:	6a 00                	push   $0x0
8010313a:	e8 c6 ff ff ff       	call   80103105 <cmos_read>
8010313f:	83 c4 04             	add    $0x4,%esp
80103142:	8b 55 08             	mov    0x8(%ebp),%edx
80103145:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103147:	6a 02                	push   $0x2
80103149:	e8 b7 ff ff ff       	call   80103105 <cmos_read>
8010314e:	83 c4 04             	add    $0x4,%esp
80103151:	8b 55 08             	mov    0x8(%ebp),%edx
80103154:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103157:	6a 04                	push   $0x4
80103159:	e8 a7 ff ff ff       	call   80103105 <cmos_read>
8010315e:	83 c4 04             	add    $0x4,%esp
80103161:	8b 55 08             	mov    0x8(%ebp),%edx
80103164:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103167:	6a 07                	push   $0x7
80103169:	e8 97 ff ff ff       	call   80103105 <cmos_read>
8010316e:	83 c4 04             	add    $0x4,%esp
80103171:	8b 55 08             	mov    0x8(%ebp),%edx
80103174:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103177:	6a 08                	push   $0x8
80103179:	e8 87 ff ff ff       	call   80103105 <cmos_read>
8010317e:	83 c4 04             	add    $0x4,%esp
80103181:	8b 55 08             	mov    0x8(%ebp),%edx
80103184:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103187:	6a 09                	push   $0x9
80103189:	e8 77 ff ff ff       	call   80103105 <cmos_read>
8010318e:	83 c4 04             	add    $0x4,%esp
80103191:	8b 55 08             	mov    0x8(%ebp),%edx
80103194:	89 42 14             	mov    %eax,0x14(%edx)
}
80103197:	90                   	nop
80103198:	c9                   	leave
80103199:	c3                   	ret

8010319a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010319a:	55                   	push   %ebp
8010319b:	89 e5                	mov    %esp,%ebp
8010319d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031a0:	6a 0b                	push   $0xb
801031a2:	e8 5e ff ff ff       	call   80103105 <cmos_read>
801031a7:	83 c4 04             	add    $0x4,%esp
801031aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031b0:	83 e0 04             	and    $0x4,%eax
801031b3:	85 c0                	test   %eax,%eax
801031b5:	0f 94 c0             	sete   %al
801031b8:	0f b6 c0             	movzbl %al,%eax
801031bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031be:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c1:	50                   	push   %eax
801031c2:	e8 6e ff ff ff       	call   80103135 <fill_rtcdate>
801031c7:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031ca:	6a 0a                	push   $0xa
801031cc:	e8 34 ff ff ff       	call   80103105 <cmos_read>
801031d1:	83 c4 04             	add    $0x4,%esp
801031d4:	25 80 00 00 00       	and    $0x80,%eax
801031d9:	85 c0                	test   %eax,%eax
801031db:	75 27                	jne    80103204 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031dd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031e0:	50                   	push   %eax
801031e1:	e8 4f ff ff ff       	call   80103135 <fill_rtcdate>
801031e6:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801031e9:	83 ec 04             	sub    $0x4,%esp
801031ec:	6a 18                	push   $0x18
801031ee:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f1:	50                   	push   %eax
801031f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f5:	50                   	push   %eax
801031f6:	e8 e9 1c 00 00       	call   80104ee4 <memcmp>
801031fb:	83 c4 10             	add    $0x10,%esp
801031fe:	85 c0                	test   %eax,%eax
80103200:	74 05                	je     80103207 <cmostime+0x6d>
80103202:	eb ba                	jmp    801031be <cmostime+0x24>
        continue;
80103204:	90                   	nop
    fill_rtcdate(&t1);
80103205:	eb b7                	jmp    801031be <cmostime+0x24>
      break;
80103207:	90                   	nop
  }

  // convert
  if(bcd) {
80103208:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010320c:	0f 84 b4 00 00 00    	je     801032c6 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103212:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103215:	c1 e8 04             	shr    $0x4,%eax
80103218:	89 c2                	mov    %eax,%edx
8010321a:	89 d0                	mov    %edx,%eax
8010321c:	c1 e0 02             	shl    $0x2,%eax
8010321f:	01 d0                	add    %edx,%eax
80103221:	01 c0                	add    %eax,%eax
80103223:	89 c2                	mov    %eax,%edx
80103225:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103228:	83 e0 0f             	and    $0xf,%eax
8010322b:	01 d0                	add    %edx,%eax
8010322d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103230:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103233:	c1 e8 04             	shr    $0x4,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	89 d0                	mov    %edx,%eax
8010323a:	c1 e0 02             	shl    $0x2,%eax
8010323d:	01 d0                	add    %edx,%eax
8010323f:	01 c0                	add    %eax,%eax
80103241:	89 c2                	mov    %eax,%edx
80103243:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103246:	83 e0 0f             	and    $0xf,%eax
80103249:	01 d0                	add    %edx,%eax
8010324b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010324e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103251:	c1 e8 04             	shr    $0x4,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	89 d0                	mov    %edx,%eax
80103258:	c1 e0 02             	shl    $0x2,%eax
8010325b:	01 d0                	add    %edx,%eax
8010325d:	01 c0                	add    %eax,%eax
8010325f:	89 c2                	mov    %eax,%edx
80103261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103264:	83 e0 0f             	and    $0xf,%eax
80103267:	01 d0                	add    %edx,%eax
80103269:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010326c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010326f:	c1 e8 04             	shr    $0x4,%eax
80103272:	89 c2                	mov    %eax,%edx
80103274:	89 d0                	mov    %edx,%eax
80103276:	c1 e0 02             	shl    $0x2,%eax
80103279:	01 d0                	add    %edx,%eax
8010327b:	01 c0                	add    %eax,%eax
8010327d:	89 c2                	mov    %eax,%edx
8010327f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103282:	83 e0 0f             	and    $0xf,%eax
80103285:	01 d0                	add    %edx,%eax
80103287:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010328a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010328d:	c1 e8 04             	shr    $0x4,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	89 d0                	mov    %edx,%eax
80103294:	c1 e0 02             	shl    $0x2,%eax
80103297:	01 d0                	add    %edx,%eax
80103299:	01 c0                	add    %eax,%eax
8010329b:	89 c2                	mov    %eax,%edx
8010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a0:	83 e0 0f             	and    $0xf,%eax
801032a3:	01 d0                	add    %edx,%eax
801032a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ab:	c1 e8 04             	shr    $0x4,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	89 d0                	mov    %edx,%eax
801032b2:	c1 e0 02             	shl    $0x2,%eax
801032b5:	01 d0                	add    %edx,%eax
801032b7:	01 c0                	add    %eax,%eax
801032b9:	89 c2                	mov    %eax,%edx
801032bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032be:	83 e0 0f             	and    $0xf,%eax
801032c1:	01 d0                	add    %edx,%eax
801032c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032c6:	8b 45 08             	mov    0x8(%ebp),%eax
801032c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cc:	89 10                	mov    %edx,(%eax)
801032ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032d1:	89 50 04             	mov    %edx,0x4(%eax)
801032d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032d7:	89 50 08             	mov    %edx,0x8(%eax)
801032da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032dd:	89 50 0c             	mov    %edx,0xc(%eax)
801032e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e3:	89 50 10             	mov    %edx,0x10(%eax)
801032e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032e9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ec:	8b 45 08             	mov    0x8(%ebp),%eax
801032ef:	8b 40 14             	mov    0x14(%eax),%eax
801032f2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032f8:	8b 45 08             	mov    0x8(%ebp),%eax
801032fb:	89 50 14             	mov    %edx,0x14(%eax)
}
801032fe:	90                   	nop
801032ff:	c9                   	leave
80103300:	c3                   	ret

80103301 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103301:	55                   	push   %ebp
80103302:	89 e5                	mov    %esp,%ebp
80103304:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103307:	83 ec 08             	sub    $0x8,%esp
8010330a:	68 b5 a6 10 80       	push   $0x8010a6b5
8010330f:	68 60 71 11 80       	push   $0x80117160
80103314:	e8 cc 18 00 00       	call   80104be5 <initlock>
80103319:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010331c:	83 ec 08             	sub    $0x8,%esp
8010331f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103322:	50                   	push   %eax
80103323:	ff 75 08             	push   0x8(%ebp)
80103326:	e8 ad e0 ff ff       	call   801013d8 <readsb>
8010332b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010332e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103331:	a3 94 71 11 80       	mov    %eax,0x80117194
  log.size = sb.nlog;
80103336:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103339:	a3 98 71 11 80       	mov    %eax,0x80117198
  log.dev = dev;
8010333e:	8b 45 08             	mov    0x8(%ebp),%eax
80103341:	a3 a4 71 11 80       	mov    %eax,0x801171a4
  recover_from_log();
80103346:	e8 b3 01 00 00       	call   801034fe <recover_from_log>
}
8010334b:	90                   	nop
8010334c:	c9                   	leave
8010334d:	c3                   	ret

8010334e <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010334e:	55                   	push   %ebp
8010334f:	89 e5                	mov    %esp,%ebp
80103351:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103354:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010335b:	e9 95 00 00 00       	jmp    801033f5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103360:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103369:	01 d0                	add    %edx,%eax
8010336b:	83 c0 01             	add    $0x1,%eax
8010336e:	89 c2                	mov    %eax,%edx
80103370:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103375:	83 ec 08             	sub    $0x8,%esp
80103378:	52                   	push   %edx
80103379:	50                   	push   %eax
8010337a:	e8 82 ce ff ff       	call   80100201 <bread>
8010337f:	83 c4 10             	add    $0x10,%esp
80103382:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103388:	83 c0 10             	add    $0x10,%eax
8010338b:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
80103392:	89 c2                	mov    %eax,%edx
80103394:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103399:	83 ec 08             	sub    $0x8,%esp
8010339c:	52                   	push   %edx
8010339d:	50                   	push   %eax
8010339e:	e8 5e ce ff ff       	call   80100201 <bread>
801033a3:	83 c4 10             	add    $0x10,%esp
801033a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033ac:	8d 50 5c             	lea    0x5c(%eax),%edx
801033af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033b2:	83 c0 5c             	add    $0x5c,%eax
801033b5:	83 ec 04             	sub    $0x4,%esp
801033b8:	68 00 02 00 00       	push   $0x200
801033bd:	52                   	push   %edx
801033be:	50                   	push   %eax
801033bf:	e8 78 1b 00 00       	call   80104f3c <memmove>
801033c4:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033c7:	83 ec 0c             	sub    $0xc,%esp
801033ca:	ff 75 ec             	push   -0x14(%ebp)
801033cd:	e8 68 ce ff ff       	call   8010023a <bwrite>
801033d2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
801033d5:	83 ec 0c             	sub    $0xc,%esp
801033d8:	ff 75 f0             	push   -0x10(%ebp)
801033db:	e8 a3 ce ff ff       	call   80100283 <brelse>
801033e0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033e3:	83 ec 0c             	sub    $0xc,%esp
801033e6:	ff 75 ec             	push   -0x14(%ebp)
801033e9:	e8 95 ce ff ff       	call   80100283 <brelse>
801033ee:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801033f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801033fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801033fd:	0f 8c 5d ff ff ff    	jl     80103360 <install_trans+0x12>
  }
}
80103403:	90                   	nop
80103404:	90                   	nop
80103405:	c9                   	leave
80103406:	c3                   	ret

80103407 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103407:	55                   	push   %ebp
80103408:	89 e5                	mov    %esp,%ebp
8010340a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010340d:	a1 94 71 11 80       	mov    0x80117194,%eax
80103412:	89 c2                	mov    %eax,%edx
80103414:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103419:	83 ec 08             	sub    $0x8,%esp
8010341c:	52                   	push   %edx
8010341d:	50                   	push   %eax
8010341e:	e8 de cd ff ff       	call   80100201 <bread>
80103423:	83 c4 10             	add    $0x10,%esp
80103426:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342c:	83 c0 5c             	add    $0x5c,%eax
8010342f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103432:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103435:	8b 00                	mov    (%eax),%eax
80103437:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  for (i = 0; i < log.lh.n; i++) {
8010343c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103443:	eb 1b                	jmp    80103460 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103445:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010344b:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010344f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103452:	83 c2 10             	add    $0x10,%edx
80103455:	89 04 95 6c 71 11 80 	mov    %eax,-0x7fee8e94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010345c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103460:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103465:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103468:	7c db                	jl     80103445 <read_head+0x3e>
  }
  brelse(buf);
8010346a:	83 ec 0c             	sub    $0xc,%esp
8010346d:	ff 75 f0             	push   -0x10(%ebp)
80103470:	e8 0e ce ff ff       	call   80100283 <brelse>
80103475:	83 c4 10             	add    $0x10,%esp
}
80103478:	90                   	nop
80103479:	c9                   	leave
8010347a:	c3                   	ret

8010347b <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010347b:	55                   	push   %ebp
8010347c:	89 e5                	mov    %esp,%ebp
8010347e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103481:	a1 94 71 11 80       	mov    0x80117194,%eax
80103486:	89 c2                	mov    %eax,%edx
80103488:	a1 a4 71 11 80       	mov    0x801171a4,%eax
8010348d:	83 ec 08             	sub    $0x8,%esp
80103490:	52                   	push   %edx
80103491:	50                   	push   %eax
80103492:	e8 6a cd ff ff       	call   80100201 <bread>
80103497:	83 c4 10             	add    $0x10,%esp
8010349a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010349d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a0:	83 c0 5c             	add    $0x5c,%eax
801034a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034a6:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
801034ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034af:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b8:	eb 1b                	jmp    801034d5 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034bd:	83 c0 10             	add    $0x10,%eax
801034c0:	8b 0c 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%ecx
801034c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034cd:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d5:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801034da:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034dd:	7c db                	jl     801034ba <write_head+0x3f>
  }
  bwrite(buf);
801034df:	83 ec 0c             	sub    $0xc,%esp
801034e2:	ff 75 f0             	push   -0x10(%ebp)
801034e5:	e8 50 cd ff ff       	call   8010023a <bwrite>
801034ea:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ed:	83 ec 0c             	sub    $0xc,%esp
801034f0:	ff 75 f0             	push   -0x10(%ebp)
801034f3:	e8 8b cd ff ff       	call   80100283 <brelse>
801034f8:	83 c4 10             	add    $0x10,%esp
}
801034fb:	90                   	nop
801034fc:	c9                   	leave
801034fd:	c3                   	ret

801034fe <recover_from_log>:

static void
recover_from_log(void)
{
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
80103501:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103504:	e8 fe fe ff ff       	call   80103407 <read_head>
  install_trans(); // if committed, copy from log to disk
80103509:	e8 40 fe ff ff       	call   8010334e <install_trans>
  log.lh.n = 0;
8010350e:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
80103515:	00 00 00 
  write_head(); // clear the log
80103518:	e8 5e ff ff ff       	call   8010347b <write_head>
}
8010351d:	90                   	nop
8010351e:	c9                   	leave
8010351f:	c3                   	ret

80103520 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103526:	83 ec 0c             	sub    $0xc,%esp
80103529:	68 60 71 11 80       	push   $0x80117160
8010352e:	e8 d4 16 00 00       	call   80104c07 <acquire>
80103533:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103536:	a1 a0 71 11 80       	mov    0x801171a0,%eax
8010353b:	85 c0                	test   %eax,%eax
8010353d:	74 17                	je     80103556 <begin_op+0x36>
      sleep(&log, &log.lock);
8010353f:	83 ec 08             	sub    $0x8,%esp
80103542:	68 60 71 11 80       	push   $0x80117160
80103547:	68 60 71 11 80       	push   $0x80117160
8010354c:	e8 6a 12 00 00       	call   801047bb <sleep>
80103551:	83 c4 10             	add    $0x10,%esp
80103554:	eb e0                	jmp    80103536 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103556:	8b 0d a8 71 11 80    	mov    0x801171a8,%ecx
8010355c:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103561:	8d 50 01             	lea    0x1(%eax),%edx
80103564:	89 d0                	mov    %edx,%eax
80103566:	c1 e0 02             	shl    $0x2,%eax
80103569:	01 d0                	add    %edx,%eax
8010356b:	01 c0                	add    %eax,%eax
8010356d:	01 c8                	add    %ecx,%eax
8010356f:	83 f8 1e             	cmp    $0x1e,%eax
80103572:	7e 17                	jle    8010358b <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103574:	83 ec 08             	sub    $0x8,%esp
80103577:	68 60 71 11 80       	push   $0x80117160
8010357c:	68 60 71 11 80       	push   $0x80117160
80103581:	e8 35 12 00 00       	call   801047bb <sleep>
80103586:	83 c4 10             	add    $0x10,%esp
80103589:	eb ab                	jmp    80103536 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010358b:	a1 9c 71 11 80       	mov    0x8011719c,%eax
80103590:	83 c0 01             	add    $0x1,%eax
80103593:	a3 9c 71 11 80       	mov    %eax,0x8011719c
      release(&log.lock);
80103598:	83 ec 0c             	sub    $0xc,%esp
8010359b:	68 60 71 11 80       	push   $0x80117160
801035a0:	e8 d0 16 00 00       	call   80104c75 <release>
801035a5:	83 c4 10             	add    $0x10,%esp
      break;
801035a8:	90                   	nop
    }
  }
}
801035a9:	90                   	nop
801035aa:	c9                   	leave
801035ab:	c3                   	ret

801035ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035ac:	55                   	push   %ebp
801035ad:	89 e5                	mov    %esp,%ebp
801035af:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035b9:	83 ec 0c             	sub    $0xc,%esp
801035bc:	68 60 71 11 80       	push   $0x80117160
801035c1:	e8 41 16 00 00       	call   80104c07 <acquire>
801035c6:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035c9:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035ce:	83 e8 01             	sub    $0x1,%eax
801035d1:	a3 9c 71 11 80       	mov    %eax,0x8011719c
  if(log.committing)
801035d6:	a1 a0 71 11 80       	mov    0x801171a0,%eax
801035db:	85 c0                	test   %eax,%eax
801035dd:	74 0d                	je     801035ec <end_op+0x40>
    panic("log.committing");
801035df:	83 ec 0c             	sub    $0xc,%esp
801035e2:	68 b9 a6 10 80       	push   $0x8010a6b9
801035e7:	e8 bd cf ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
801035ec:	a1 9c 71 11 80       	mov    0x8011719c,%eax
801035f1:	85 c0                	test   %eax,%eax
801035f3:	75 13                	jne    80103608 <end_op+0x5c>
    do_commit = 1;
801035f5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035fc:	c7 05 a0 71 11 80 01 	movl   $0x1,0x801171a0
80103603:	00 00 00 
80103606:	eb 10                	jmp    80103618 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103608:	83 ec 0c             	sub    $0xc,%esp
8010360b:	68 60 71 11 80       	push   $0x80117160
80103610:	e8 8d 12 00 00       	call   801048a2 <wakeup>
80103615:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103618:	83 ec 0c             	sub    $0xc,%esp
8010361b:	68 60 71 11 80       	push   $0x80117160
80103620:	e8 50 16 00 00       	call   80104c75 <release>
80103625:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103628:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010362c:	74 3f                	je     8010366d <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010362e:	e8 f6 00 00 00       	call   80103729 <commit>
    acquire(&log.lock);
80103633:	83 ec 0c             	sub    $0xc,%esp
80103636:	68 60 71 11 80       	push   $0x80117160
8010363b:	e8 c7 15 00 00       	call   80104c07 <acquire>
80103640:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103643:	c7 05 a0 71 11 80 00 	movl   $0x0,0x801171a0
8010364a:	00 00 00 
    wakeup(&log);
8010364d:	83 ec 0c             	sub    $0xc,%esp
80103650:	68 60 71 11 80       	push   $0x80117160
80103655:	e8 48 12 00 00       	call   801048a2 <wakeup>
8010365a:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010365d:	83 ec 0c             	sub    $0xc,%esp
80103660:	68 60 71 11 80       	push   $0x80117160
80103665:	e8 0b 16 00 00       	call   80104c75 <release>
8010366a:	83 c4 10             	add    $0x10,%esp
  }
}
8010366d:	90                   	nop
8010366e:	c9                   	leave
8010366f:	c3                   	ret

80103670 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103670:	55                   	push   %ebp
80103671:	89 e5                	mov    %esp,%ebp
80103673:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010367d:	e9 95 00 00 00       	jmp    80103717 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103682:	8b 15 94 71 11 80    	mov    0x80117194,%edx
80103688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368b:	01 d0                	add    %edx,%eax
8010368d:	83 c0 01             	add    $0x1,%eax
80103690:	89 c2                	mov    %eax,%edx
80103692:	a1 a4 71 11 80       	mov    0x801171a4,%eax
80103697:	83 ec 08             	sub    $0x8,%esp
8010369a:	52                   	push   %edx
8010369b:	50                   	push   %eax
8010369c:	e8 60 cb ff ff       	call   80100201 <bread>
801036a1:	83 c4 10             	add    $0x10,%esp
801036a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036aa:	83 c0 10             	add    $0x10,%eax
801036ad:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801036b4:	89 c2                	mov    %eax,%edx
801036b6:	a1 a4 71 11 80       	mov    0x801171a4,%eax
801036bb:	83 ec 08             	sub    $0x8,%esp
801036be:	52                   	push   %edx
801036bf:	50                   	push   %eax
801036c0:	e8 3c cb ff ff       	call   80100201 <bread>
801036c5:	83 c4 10             	add    $0x10,%esp
801036c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ce:	8d 50 5c             	lea    0x5c(%eax),%edx
801036d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d4:	83 c0 5c             	add    $0x5c,%eax
801036d7:	83 ec 04             	sub    $0x4,%esp
801036da:	68 00 02 00 00       	push   $0x200
801036df:	52                   	push   %edx
801036e0:	50                   	push   %eax
801036e1:	e8 56 18 00 00       	call   80104f3c <memmove>
801036e6:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036e9:	83 ec 0c             	sub    $0xc,%esp
801036ec:	ff 75 f0             	push   -0x10(%ebp)
801036ef:	e8 46 cb ff ff       	call   8010023a <bwrite>
801036f4:	83 c4 10             	add    $0x10,%esp
    brelse(from);
801036f7:	83 ec 0c             	sub    $0xc,%esp
801036fa:	ff 75 ec             	push   -0x14(%ebp)
801036fd:	e8 81 cb ff ff       	call   80100283 <brelse>
80103702:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103705:	83 ec 0c             	sub    $0xc,%esp
80103708:	ff 75 f0             	push   -0x10(%ebp)
8010370b:	e8 73 cb ff ff       	call   80100283 <brelse>
80103710:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103713:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103717:	a1 a8 71 11 80       	mov    0x801171a8,%eax
8010371c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010371f:	0f 8c 5d ff ff ff    	jl     80103682 <write_log+0x12>
  }
}
80103725:	90                   	nop
80103726:	90                   	nop
80103727:	c9                   	leave
80103728:	c3                   	ret

80103729 <commit>:

static void
commit()
{
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010372f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	7e 1e                	jle    80103756 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103738:	e8 33 ff ff ff       	call   80103670 <write_log>
    write_head();    // Write header to disk -- the real commit
8010373d:	e8 39 fd ff ff       	call   8010347b <write_head>
    install_trans(); // Now install writes to home locations
80103742:	e8 07 fc ff ff       	call   8010334e <install_trans>
    log.lh.n = 0;
80103747:	c7 05 a8 71 11 80 00 	movl   $0x0,0x801171a8
8010374e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103751:	e8 25 fd ff ff       	call   8010347b <write_head>
  }
}
80103756:	90                   	nop
80103757:	c9                   	leave
80103758:	c3                   	ret

80103759 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103759:	55                   	push   %ebp
8010375a:	89 e5                	mov    %esp,%ebp
8010375c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010375f:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103764:	83 f8 1d             	cmp    $0x1d,%eax
80103767:	7f 12                	jg     8010377b <log_write+0x22>
80103769:	8b 15 a8 71 11 80    	mov    0x801171a8,%edx
8010376f:	a1 98 71 11 80       	mov    0x80117198,%eax
80103774:	83 e8 01             	sub    $0x1,%eax
80103777:	39 c2                	cmp    %eax,%edx
80103779:	7c 0d                	jl     80103788 <log_write+0x2f>
    panic("too big a transaction");
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	68 c8 a6 10 80       	push   $0x8010a6c8
80103783:	e8 21 ce ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
80103788:	a1 9c 71 11 80       	mov    0x8011719c,%eax
8010378d:	85 c0                	test   %eax,%eax
8010378f:	7f 0d                	jg     8010379e <log_write+0x45>
    panic("log_write outside of trans");
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	68 de a6 10 80       	push   $0x8010a6de
80103799:	e8 0b ce ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
8010379e:	83 ec 0c             	sub    $0xc,%esp
801037a1:	68 60 71 11 80       	push   $0x80117160
801037a6:	e8 5c 14 00 00       	call   80104c07 <acquire>
801037ab:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037b5:	eb 1d                	jmp    801037d4 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ba:	83 c0 10             	add    $0x10,%eax
801037bd:	8b 04 85 6c 71 11 80 	mov    -0x7fee8e94(,%eax,4),%eax
801037c4:	89 c2                	mov    %eax,%edx
801037c6:	8b 45 08             	mov    0x8(%ebp),%eax
801037c9:	8b 40 08             	mov    0x8(%eax),%eax
801037cc:	39 c2                	cmp    %eax,%edx
801037ce:	74 10                	je     801037e0 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801037d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d4:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037d9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037dc:	7c d9                	jl     801037b7 <log_write+0x5e>
801037de:	eb 01                	jmp    801037e1 <log_write+0x88>
      break;
801037e0:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037e1:	8b 45 08             	mov    0x8(%ebp),%eax
801037e4:	8b 40 08             	mov    0x8(%eax),%eax
801037e7:	89 c2                	mov    %eax,%edx
801037e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ec:	83 c0 10             	add    $0x10,%eax
801037ef:	89 14 85 6c 71 11 80 	mov    %edx,-0x7fee8e94(,%eax,4)
  if (i == log.lh.n)
801037f6:	a1 a8 71 11 80       	mov    0x801171a8,%eax
801037fb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801037fe:	75 0d                	jne    8010380d <log_write+0xb4>
    log.lh.n++;
80103800:	a1 a8 71 11 80       	mov    0x801171a8,%eax
80103805:	83 c0 01             	add    $0x1,%eax
80103808:	a3 a8 71 11 80       	mov    %eax,0x801171a8
  b->flags |= B_DIRTY; // prevent eviction
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 00                	mov    (%eax),%eax
80103812:	83 c8 04             	or     $0x4,%eax
80103815:	89 c2                	mov    %eax,%edx
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381c:	83 ec 0c             	sub    $0xc,%esp
8010381f:	68 60 71 11 80       	push   $0x80117160
80103824:	e8 4c 14 00 00       	call   80104c75 <release>
80103829:	83 c4 10             	add    $0x10,%esp
}
8010382c:	90                   	nop
8010382d:	c9                   	leave
8010382e:	c3                   	ret

8010382f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010382f:	55                   	push   %ebp
80103830:	89 e5                	mov    %esp,%ebp
80103832:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103835:	8b 55 08             	mov    0x8(%ebp),%edx
80103838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010383b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383e:	f0 87 02             	lock xchg %eax,(%edx)
80103841:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103847:	c9                   	leave
80103848:	c3                   	ret

80103849 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103849:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010384d:	83 e4 f0             	and    $0xfffffff0,%esp
80103850:	ff 71 fc             	push   -0x4(%ecx)
80103853:	55                   	push   %ebp
80103854:	89 e5                	mov    %esp,%ebp
80103856:	51                   	push   %ecx
80103857:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
8010385a:	e8 83 4a 00 00       	call   801082e2 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010385f:	83 ec 08             	sub    $0x8,%esp
80103862:	68 00 00 40 80       	push   $0x80400000
80103867:	68 00 c0 11 80       	push   $0x8011c000
8010386c:	e8 e4 f2 ff ff       	call   80102b55 <kinit1>
80103871:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103874:	e8 86 40 00 00       	call   801078ff <kvmalloc>
  mpinit_uefi();
80103879:	e8 2d 48 00 00       	call   801080ab <mpinit_uefi>
  lapicinit();     // interrupt controller
8010387e:	e8 3f f6 ff ff       	call   80102ec2 <lapicinit>
  seginit();       // segment descriptors
80103883:	e8 0e 3b 00 00       	call   80107396 <seginit>
  picinit();    // disable pic
80103888:	e8 9b 01 00 00       	call   80103a28 <picinit>
  ioapicinit();    // another interrupt controller
8010388d:	e8 de f1 ff ff       	call   80102a70 <ioapicinit>
  consoleinit();   // console hardware
80103892:	e8 72 d2 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
80103897:	e8 93 2e 00 00       	call   8010672f <uartinit>
  pinit();         // process table
8010389c:	e8 c0 05 00 00       	call   80103e61 <pinit>
  tvinit();        // trap vectors
801038a1:	e8 e2 29 00 00       	call   80106288 <tvinit>
  binit();         // buffer cache
801038a6:	e8 bb c7 ff ff       	call   80100066 <binit>
  fileinit();      // file table
801038ab:	e8 19 d7 ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801038b0:	e8 74 ed ff ff       	call   80102629 <ideinit>
  startothers();   // start other processors
801038b5:	e8 8a 00 00 00       	call   80103944 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	68 00 00 00 a0       	push   $0xa0000000
801038c2:	68 00 00 40 80       	push   $0x80400000
801038c7:	e8 c2 f2 ff ff       	call   80102b8e <kinit2>
801038cc:	83 c4 10             	add    $0x10,%esp
  pci_init();
801038cf:	e8 69 4c 00 00       	call   8010853d <pci_init>
  arp_scan();
801038d4:	e8 9e 59 00 00       	call   80109277 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801038d9:	e8 61 07 00 00       	call   8010403f <userinit>

  mpmain();        // finish this processor's setup
801038de:	e8 1a 00 00 00       	call   801038fd <mpmain>

801038e3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038e3:	55                   	push   %ebp
801038e4:	89 e5                	mov    %esp,%ebp
801038e6:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038e9:	e8 29 40 00 00       	call   80107917 <switchkvm>
  seginit();
801038ee:	e8 a3 3a 00 00       	call   80107396 <seginit>
  lapicinit();
801038f3:	e8 ca f5 ff ff       	call   80102ec2 <lapicinit>
  mpmain();
801038f8:	e8 00 00 00 00       	call   801038fd <mpmain>

801038fd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038fd:	55                   	push   %ebp
801038fe:	89 e5                	mov    %esp,%ebp
80103900:	53                   	push   %ebx
80103901:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103904:	e8 76 05 00 00       	call   80103e7f <cpuid>
80103909:	89 c3                	mov    %eax,%ebx
8010390b:	e8 6f 05 00 00       	call   80103e7f <cpuid>
80103910:	83 ec 04             	sub    $0x4,%esp
80103913:	53                   	push   %ebx
80103914:	50                   	push   %eax
80103915:	68 f9 a6 10 80       	push   $0x8010a6f9
8010391a:	e8 d5 ca ff ff       	call   801003f4 <cprintf>
8010391f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103922:	e8 d7 2a 00 00       	call   801063fe <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103927:	e8 6e 05 00 00       	call   80103e9a <mycpu>
8010392c:	05 a0 00 00 00       	add    $0xa0,%eax
80103931:	83 ec 08             	sub    $0x8,%esp
80103934:	6a 01                	push   $0x1
80103936:	50                   	push   %eax
80103937:	e8 f3 fe ff ff       	call   8010382f <xchg>
8010393c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010393f:	e8 86 0c 00 00       	call   801045ca <scheduler>

80103944 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
8010394a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103951:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103956:	83 ec 04             	sub    $0x4,%esp
80103959:	50                   	push   %eax
8010395a:	68 18 f5 10 80       	push   $0x8010f518
8010395f:	ff 75 f0             	push   -0x10(%ebp)
80103962:	e8 d5 15 00 00       	call   80104f3c <memmove>
80103967:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
8010396a:	c7 45 f4 c0 9a 11 80 	movl   $0x80119ac0,-0xc(%ebp)
80103971:	eb 79                	jmp    801039ec <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103973:	e8 22 05 00 00       	call   80103e9a <mycpu>
80103978:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397b:	74 67                	je     801039e4 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010397d:	e8 08 f3 ff ff       	call   80102c8a <kalloc>
80103982:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103988:	83 e8 04             	sub    $0x4,%eax
8010398b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010398e:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103994:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103999:	83 e8 08             	sub    $0x8,%eax
8010399c:	c7 00 e3 38 10 80    	movl   $0x801038e3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801039a2:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801039a7:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b0:	83 e8 0c             	sub    $0xc,%eax
801039b3:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801039b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c1:	0f b6 00             	movzbl (%eax),%eax
801039c4:	0f b6 c0             	movzbl %al,%eax
801039c7:	83 ec 08             	sub    $0x8,%esp
801039ca:	52                   	push   %edx
801039cb:	50                   	push   %eax
801039cc:	e8 50 f6 ff ff       	call   80103021 <lapicstartap>
801039d1:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039d4:	90                   	nop
801039d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039d8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039de:	85 c0                	test   %eax,%eax
801039e0:	74 f3                	je     801039d5 <startothers+0x91>
801039e2:	eb 01                	jmp    801039e5 <startothers+0xa1>
      continue;
801039e4:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
801039e5:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039ec:	a1 80 9d 11 80       	mov    0x80119d80,%eax
801039f1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f7:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
801039fc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039ff:	0f 82 6e ff ff ff    	jb     80103973 <startothers+0x2f>
      ;
  }
}
80103a05:	90                   	nop
80103a06:	90                   	nop
80103a07:	c9                   	leave
80103a08:	c3                   	ret

80103a09 <outb>:
{
80103a09:	55                   	push   %ebp
80103a0a:	89 e5                	mov    %esp,%ebp
80103a0c:	83 ec 08             	sub    $0x8,%esp
80103a0f:	8b 55 08             	mov    0x8(%ebp),%edx
80103a12:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a15:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a19:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a1c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a20:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a24:	ee                   	out    %al,(%dx)
}
80103a25:	90                   	nop
80103a26:	c9                   	leave
80103a27:	c3                   	ret

80103a28 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103a28:	55                   	push   %ebp
80103a29:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103a2b:	68 ff 00 00 00       	push   $0xff
80103a30:	6a 21                	push   $0x21
80103a32:	e8 d2 ff ff ff       	call   80103a09 <outb>
80103a37:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103a3a:	68 ff 00 00 00       	push   $0xff
80103a3f:	68 a1 00 00 00       	push   $0xa1
80103a44:	e8 c0 ff ff ff       	call   80103a09 <outb>
80103a49:	83 c4 08             	add    $0x8,%esp
}
80103a4c:	90                   	nop
80103a4d:	c9                   	leave
80103a4e:	c3                   	ret

80103a4f <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103a4f:	55                   	push   %ebp
80103a50:	89 e5                	mov    %esp,%ebp
80103a52:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103a55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103a65:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a68:	8b 10                	mov    (%eax),%edx
80103a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6d:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103a6f:	e8 73 d5 ff ff       	call   80100fe7 <filealloc>
80103a74:	8b 55 08             	mov    0x8(%ebp),%edx
80103a77:	89 02                	mov    %eax,(%edx)
80103a79:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7c:	8b 00                	mov    (%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	0f 84 c8 00 00 00    	je     80103b4e <pipealloc+0xff>
80103a86:	e8 5c d5 ff ff       	call   80100fe7 <filealloc>
80103a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a8e:	89 02                	mov    %eax,(%edx)
80103a90:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a93:	8b 00                	mov    (%eax),%eax
80103a95:	85 c0                	test   %eax,%eax
80103a97:	0f 84 b1 00 00 00    	je     80103b4e <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103a9d:	e8 e8 f1 ff ff       	call   80102c8a <kalloc>
80103aa2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103aa5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103aa9:	0f 84 a2 00 00 00    	je     80103b51 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
80103aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab2:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ab9:	00 00 00 
  p->writeopen = 1;
80103abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abf:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103ac6:	00 00 00 
  p->nwrite = 0;
80103ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acc:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103ad3:	00 00 00 
  p->nread = 0;
80103ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103ae0:	00 00 00 
  initlock(&p->lock, "pipe");
80103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae6:	83 ec 08             	sub    $0x8,%esp
80103ae9:	68 0d a7 10 80       	push   $0x8010a70d
80103aee:	50                   	push   %eax
80103aef:	e8 f1 10 00 00       	call   80104be5 <initlock>
80103af4:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103af7:	8b 45 08             	mov    0x8(%ebp),%eax
80103afa:	8b 00                	mov    (%eax),%eax
80103afc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103b02:	8b 45 08             	mov    0x8(%ebp),%eax
80103b05:	8b 00                	mov    (%eax),%eax
80103b07:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b0e:	8b 00                	mov    (%eax),%eax
80103b10:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103b14:	8b 45 08             	mov    0x8(%ebp),%eax
80103b17:	8b 00                	mov    (%eax),%eax
80103b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b1c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b22:	8b 00                	mov    (%eax),%eax
80103b24:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b2d:	8b 00                	mov    (%eax),%eax
80103b2f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103b33:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b36:	8b 00                	mov    (%eax),%eax
80103b38:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b3f:	8b 00                	mov    (%eax),%eax
80103b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b44:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103b47:	b8 00 00 00 00       	mov    $0x0,%eax
80103b4c:	eb 51                	jmp    80103b9f <pipealloc+0x150>
    goto bad;
80103b4e:	90                   	nop
80103b4f:	eb 01                	jmp    80103b52 <pipealloc+0x103>
    goto bad;
80103b51:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103b52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b56:	74 0e                	je     80103b66 <pipealloc+0x117>
    kfree((char*)p);
80103b58:	83 ec 0c             	sub    $0xc,%esp
80103b5b:	ff 75 f4             	push   -0xc(%ebp)
80103b5e:	e8 8d f0 ff ff       	call   80102bf0 <kfree>
80103b63:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103b66:	8b 45 08             	mov    0x8(%ebp),%eax
80103b69:	8b 00                	mov    (%eax),%eax
80103b6b:	85 c0                	test   %eax,%eax
80103b6d:	74 11                	je     80103b80 <pipealloc+0x131>
    fileclose(*f0);
80103b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b72:	8b 00                	mov    (%eax),%eax
80103b74:	83 ec 0c             	sub    $0xc,%esp
80103b77:	50                   	push   %eax
80103b78:	e8 28 d5 ff ff       	call   801010a5 <fileclose>
80103b7d:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103b80:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b83:	8b 00                	mov    (%eax),%eax
80103b85:	85 c0                	test   %eax,%eax
80103b87:	74 11                	je     80103b9a <pipealloc+0x14b>
    fileclose(*f1);
80103b89:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b8c:	8b 00                	mov    (%eax),%eax
80103b8e:	83 ec 0c             	sub    $0xc,%esp
80103b91:	50                   	push   %eax
80103b92:	e8 0e d5 ff ff       	call   801010a5 <fileclose>
80103b97:	83 c4 10             	add    $0x10,%esp
  return -1;
80103b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103b9f:	c9                   	leave
80103ba0:	c3                   	ret

80103ba1 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ba1:	55                   	push   %ebp
80103ba2:	89 e5                	mov    %esp,%ebp
80103ba4:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80103ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80103baa:	83 ec 0c             	sub    $0xc,%esp
80103bad:	50                   	push   %eax
80103bae:	e8 54 10 00 00       	call   80104c07 <acquire>
80103bb3:	83 c4 10             	add    $0x10,%esp
  if(writable){
80103bb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103bba:	74 23                	je     80103bdf <pipeclose+0x3e>
    p->writeopen = 0;
80103bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bbf:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103bc6:	00 00 00 
    wakeup(&p->nread);
80103bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcc:	05 34 02 00 00       	add    $0x234,%eax
80103bd1:	83 ec 0c             	sub    $0xc,%esp
80103bd4:	50                   	push   %eax
80103bd5:	e8 c8 0c 00 00       	call   801048a2 <wakeup>
80103bda:	83 c4 10             	add    $0x10,%esp
80103bdd:	eb 21                	jmp    80103c00 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80103bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80103be2:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103be9:	00 00 00 
    wakeup(&p->nwrite);
80103bec:	8b 45 08             	mov    0x8(%ebp),%eax
80103bef:	05 38 02 00 00       	add    $0x238,%eax
80103bf4:	83 ec 0c             	sub    $0xc,%esp
80103bf7:	50                   	push   %eax
80103bf8:	e8 a5 0c 00 00       	call   801048a2 <wakeup>
80103bfd:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103c00:	8b 45 08             	mov    0x8(%ebp),%eax
80103c03:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c09:	85 c0                	test   %eax,%eax
80103c0b:	75 2c                	jne    80103c39 <pipeclose+0x98>
80103c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c10:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103c16:	85 c0                	test   %eax,%eax
80103c18:	75 1f                	jne    80103c39 <pipeclose+0x98>
    release(&p->lock);
80103c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1d:	83 ec 0c             	sub    $0xc,%esp
80103c20:	50                   	push   %eax
80103c21:	e8 4f 10 00 00       	call   80104c75 <release>
80103c26:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103c29:	83 ec 0c             	sub    $0xc,%esp
80103c2c:	ff 75 08             	push   0x8(%ebp)
80103c2f:	e8 bc ef ff ff       	call   80102bf0 <kfree>
80103c34:	83 c4 10             	add    $0x10,%esp
80103c37:	eb 10                	jmp    80103c49 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103c39:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3c:	83 ec 0c             	sub    $0xc,%esp
80103c3f:	50                   	push   %eax
80103c40:	e8 30 10 00 00       	call   80104c75 <release>
80103c45:	83 c4 10             	add    $0x10,%esp
}
80103c48:	90                   	nop
80103c49:	90                   	nop
80103c4a:	c9                   	leave
80103c4b:	c3                   	ret

80103c4c <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103c4c:	55                   	push   %ebp
80103c4d:	89 e5                	mov    %esp,%ebp
80103c4f:	53                   	push   %ebx
80103c50:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103c53:	8b 45 08             	mov    0x8(%ebp),%eax
80103c56:	83 ec 0c             	sub    $0xc,%esp
80103c59:	50                   	push   %eax
80103c5a:	e8 a8 0f 00 00       	call   80104c07 <acquire>
80103c5f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103c62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c69:	e9 ad 00 00 00       	jmp    80103d1b <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80103c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103c71:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103c77:	85 c0                	test   %eax,%eax
80103c79:	74 0c                	je     80103c87 <pipewrite+0x3b>
80103c7b:	e8 92 02 00 00       	call   80103f12 <myproc>
80103c80:	8b 40 24             	mov    0x24(%eax),%eax
80103c83:	85 c0                	test   %eax,%eax
80103c85:	74 19                	je     80103ca0 <pipewrite+0x54>
        release(&p->lock);
80103c87:	8b 45 08             	mov    0x8(%ebp),%eax
80103c8a:	83 ec 0c             	sub    $0xc,%esp
80103c8d:	50                   	push   %eax
80103c8e:	e8 e2 0f 00 00       	call   80104c75 <release>
80103c93:	83 c4 10             	add    $0x10,%esp
        return -1;
80103c96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103c9b:	e9 a9 00 00 00       	jmp    80103d49 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
80103ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca3:	05 34 02 00 00       	add    $0x234,%eax
80103ca8:	83 ec 0c             	sub    $0xc,%esp
80103cab:	50                   	push   %eax
80103cac:	e8 f1 0b 00 00       	call   801048a2 <wakeup>
80103cb1:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb7:	8b 55 08             	mov    0x8(%ebp),%edx
80103cba:	81 c2 38 02 00 00    	add    $0x238,%edx
80103cc0:	83 ec 08             	sub    $0x8,%esp
80103cc3:	50                   	push   %eax
80103cc4:	52                   	push   %edx
80103cc5:	e8 f1 0a 00 00       	call   801047bb <sleep>
80103cca:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103cdf:	05 00 02 00 00       	add    $0x200,%eax
80103ce4:	39 c2                	cmp    %eax,%edx
80103ce6:	74 86                	je     80103c6e <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103ce8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cee:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80103cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf4:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103cfa:	8d 48 01             	lea    0x1(%eax),%ecx
80103cfd:	8b 55 08             	mov    0x8(%ebp),%edx
80103d00:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103d06:	25 ff 01 00 00       	and    $0x1ff,%eax
80103d0b:	89 c1                	mov    %eax,%ecx
80103d0d:	0f b6 13             	movzbl (%ebx),%edx
80103d10:	8b 45 08             	mov    0x8(%ebp),%eax
80103d13:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103d17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1e:	3b 45 10             	cmp    0x10(%ebp),%eax
80103d21:	7c aa                	jl     80103ccd <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103d23:	8b 45 08             	mov    0x8(%ebp),%eax
80103d26:	05 34 02 00 00       	add    $0x234,%eax
80103d2b:	83 ec 0c             	sub    $0xc,%esp
80103d2e:	50                   	push   %eax
80103d2f:	e8 6e 0b 00 00       	call   801048a2 <wakeup>
80103d34:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103d37:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3a:	83 ec 0c             	sub    $0xc,%esp
80103d3d:	50                   	push   %eax
80103d3e:	e8 32 0f 00 00       	call   80104c75 <release>
80103d43:	83 c4 10             	add    $0x10,%esp
  return n;
80103d46:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103d49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d4c:	c9                   	leave
80103d4d:	c3                   	ret

80103d4e <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103d4e:	55                   	push   %ebp
80103d4f:	89 e5                	mov    %esp,%ebp
80103d51:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103d54:	8b 45 08             	mov    0x8(%ebp),%eax
80103d57:	83 ec 0c             	sub    $0xc,%esp
80103d5a:	50                   	push   %eax
80103d5b:	e8 a7 0e 00 00       	call   80104c07 <acquire>
80103d60:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103d63:	eb 3e                	jmp    80103da3 <piperead+0x55>
    if(myproc()->killed){
80103d65:	e8 a8 01 00 00       	call   80103f12 <myproc>
80103d6a:	8b 40 24             	mov    0x24(%eax),%eax
80103d6d:	85 c0                	test   %eax,%eax
80103d6f:	74 19                	je     80103d8a <piperead+0x3c>
      release(&p->lock);
80103d71:	8b 45 08             	mov    0x8(%ebp),%eax
80103d74:	83 ec 0c             	sub    $0xc,%esp
80103d77:	50                   	push   %eax
80103d78:	e8 f8 0e 00 00       	call   80104c75 <release>
80103d7d:	83 c4 10             	add    $0x10,%esp
      return -1;
80103d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d85:	e9 be 00 00 00       	jmp    80103e48 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8d:	8b 55 08             	mov    0x8(%ebp),%edx
80103d90:	81 c2 34 02 00 00    	add    $0x234,%edx
80103d96:	83 ec 08             	sub    $0x8,%esp
80103d99:	50                   	push   %eax
80103d9a:	52                   	push   %edx
80103d9b:	e8 1b 0a 00 00       	call   801047bb <sleep>
80103da0:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103da3:	8b 45 08             	mov    0x8(%ebp),%eax
80103da6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dac:	8b 45 08             	mov    0x8(%ebp),%eax
80103daf:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103db5:	39 c2                	cmp    %eax,%edx
80103db7:	75 0d                	jne    80103dc6 <piperead+0x78>
80103db9:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103dc2:	85 c0                	test   %eax,%eax
80103dc4:	75 9f                	jne    80103d65 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103dc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dcd:	eb 48                	jmp    80103e17 <piperead+0xc9>
    if(p->nread == p->nwrite)
80103dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103de1:	39 c2                	cmp    %eax,%edx
80103de3:	74 3c                	je     80103e21 <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103de5:	8b 45 08             	mov    0x8(%ebp),%eax
80103de8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103dee:	8d 48 01             	lea    0x1(%eax),%ecx
80103df1:	8b 55 08             	mov    0x8(%ebp),%edx
80103df4:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103dfa:	25 ff 01 00 00       	and    $0x1ff,%eax
80103dff:	89 c1                	mov    %eax,%ecx
80103e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e04:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e07:	01 c2                	add    %eax,%edx
80103e09:	8b 45 08             	mov    0x8(%ebp),%eax
80103e0c:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80103e11:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103e13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e1a:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e1d:	7c b0                	jl     80103dcf <piperead+0x81>
80103e1f:	eb 01                	jmp    80103e22 <piperead+0xd4>
      break;
80103e21:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103e22:	8b 45 08             	mov    0x8(%ebp),%eax
80103e25:	05 38 02 00 00       	add    $0x238,%eax
80103e2a:	83 ec 0c             	sub    $0xc,%esp
80103e2d:	50                   	push   %eax
80103e2e:	e8 6f 0a 00 00       	call   801048a2 <wakeup>
80103e33:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103e36:	8b 45 08             	mov    0x8(%ebp),%eax
80103e39:	83 ec 0c             	sub    $0xc,%esp
80103e3c:	50                   	push   %eax
80103e3d:	e8 33 0e 00 00       	call   80104c75 <release>
80103e42:	83 c4 10             	add    $0x10,%esp
  return i;
80103e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103e48:	c9                   	leave
80103e49:	c3                   	ret

80103e4a <readeflags>:
{
80103e4a:	55                   	push   %ebp
80103e4b:	89 e5                	mov    %esp,%ebp
80103e4d:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e50:	9c                   	pushf
80103e51:	58                   	pop    %eax
80103e52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103e55:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103e58:	c9                   	leave
80103e59:	c3                   	ret

80103e5a <sti>:
{
80103e5a:	55                   	push   %ebp
80103e5b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103e5d:	fb                   	sti
}
80103e5e:	90                   	nop
80103e5f:	5d                   	pop    %ebp
80103e60:	c3                   	ret

80103e61 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103e61:	55                   	push   %ebp
80103e62:	89 e5                	mov    %esp,%ebp
80103e64:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103e67:	83 ec 08             	sub    $0x8,%esp
80103e6a:	68 14 a7 10 80       	push   $0x8010a714
80103e6f:	68 40 72 11 80       	push   $0x80117240
80103e74:	e8 6c 0d 00 00       	call   80104be5 <initlock>
80103e79:	83 c4 10             	add    $0x10,%esp
}
80103e7c:	90                   	nop
80103e7d:	c9                   	leave
80103e7e:	c3                   	ret

80103e7f <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80103e7f:	55                   	push   %ebp
80103e80:	89 e5                	mov    %esp,%ebp
80103e82:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e85:	e8 10 00 00 00       	call   80103e9a <mycpu>
80103e8a:	2d c0 9a 11 80       	sub    $0x80119ac0,%eax
80103e8f:	c1 f8 04             	sar    $0x4,%eax
80103e92:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103e98:	c9                   	leave
80103e99:	c3                   	ret

80103e9a <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103e9a:	55                   	push   %ebp
80103e9b:	89 e5                	mov    %esp,%ebp
80103e9d:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
80103ea0:	e8 a5 ff ff ff       	call   80103e4a <readeflags>
80103ea5:	25 00 02 00 00       	and    $0x200,%eax
80103eaa:	85 c0                	test   %eax,%eax
80103eac:	74 0d                	je     80103ebb <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
80103eae:	83 ec 0c             	sub    $0xc,%esp
80103eb1:	68 1c a7 10 80       	push   $0x8010a71c
80103eb6:	e8 ee c6 ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
80103ebb:	e8 1e f1 ff ff       	call   80102fde <lapicid>
80103ec0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103ec3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103eca:	eb 2d                	jmp    80103ef9 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
80103ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ecf:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103ed5:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80103eda:	0f b6 00             	movzbl (%eax),%eax
80103edd:	0f b6 c0             	movzbl %al,%eax
80103ee0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103ee3:	75 10                	jne    80103ef5 <mycpu+0x5b>
      return &cpus[i];
80103ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103eee:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
80103ef3:	eb 1b                	jmp    80103f10 <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103ef5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ef9:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80103efe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103f01:	7c c9                	jl     80103ecc <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103f03:	83 ec 0c             	sub    $0xc,%esp
80103f06:	68 42 a7 10 80       	push   $0x8010a742
80103f0b:	e8 99 c6 ff ff       	call   801005a9 <panic>
}
80103f10:	c9                   	leave
80103f11:	c3                   	ret

80103f12 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103f12:	55                   	push   %ebp
80103f13:	89 e5                	mov    %esp,%ebp
80103f15:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103f18:	e8 55 0e 00 00       	call   80104d72 <pushcli>
  c = mycpu();
80103f1d:	e8 78 ff ff ff       	call   80103e9a <mycpu>
80103f22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f28:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103f2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103f31:	e8 89 0e 00 00       	call   80104dbf <popcli>
  return p;
80103f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f39:	c9                   	leave
80103f3a:	c3                   	ret

80103f3b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103f3b:	55                   	push   %ebp
80103f3c:	89 e5                	mov    %esp,%ebp
80103f3e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103f41:	83 ec 0c             	sub    $0xc,%esp
80103f44:	68 40 72 11 80       	push   $0x80117240
80103f49:	e8 b9 0c 00 00       	call   80104c07 <acquire>
80103f4e:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f51:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80103f58:	eb 0e                	jmp    80103f68 <allocproc+0x2d>
    if(p->state == UNUSED){
80103f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5d:	8b 40 0c             	mov    0xc(%eax),%eax
80103f60:	85 c0                	test   %eax,%eax
80103f62:	74 27                	je     80103f8b <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103f64:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103f68:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80103f6f:	72 e9                	jb     80103f5a <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103f71:	83 ec 0c             	sub    $0xc,%esp
80103f74:	68 40 72 11 80       	push   $0x80117240
80103f79:	e8 f7 0c 00 00       	call   80104c75 <release>
80103f7e:	83 c4 10             	add    $0x10,%esp
  return 0;
80103f81:	b8 00 00 00 00       	mov    $0x0,%eax
80103f86:	e9 b2 00 00 00       	jmp    8010403d <allocproc+0x102>
      goto found;
80103f8b:	90                   	nop

found:
  p->state = EMBRYO;
80103f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8f:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103f96:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103f9b:	8d 50 01             	lea    0x1(%eax),%edx
80103f9e:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103fa4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fa7:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103faa:	83 ec 0c             	sub    $0xc,%esp
80103fad:	68 40 72 11 80       	push   $0x80117240
80103fb2:	e8 be 0c 00 00       	call   80104c75 <release>
80103fb7:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103fba:	e8 cb ec ff ff       	call   80102c8a <kalloc>
80103fbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fc2:	89 42 08             	mov    %eax,0x8(%edx)
80103fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc8:	8b 40 08             	mov    0x8(%eax),%eax
80103fcb:	85 c0                	test   %eax,%eax
80103fcd:	75 11                	jne    80103fe0 <allocproc+0xa5>
    p->state = UNUSED;
80103fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103fd9:	b8 00 00 00 00       	mov    $0x0,%eax
80103fde:	eb 5d                	jmp    8010403d <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe3:	8b 40 08             	mov    0x8(%eax),%eax
80103fe6:	05 00 10 00 00       	add    $0x1000,%eax
80103feb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103fee:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ff8:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103ffb:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103fff:	ba 42 62 10 80       	mov    $0x80106242,%edx
80104004:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104007:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104009:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010400d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104010:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104013:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104019:	8b 40 1c             	mov    0x1c(%eax),%eax
8010401c:	83 ec 04             	sub    $0x4,%esp
8010401f:	6a 14                	push   $0x14
80104021:	6a 00                	push   $0x0
80104023:	50                   	push   %eax
80104024:	e8 54 0e 00 00       	call   80104e7d <memset>
80104029:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010402c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104032:	ba 75 47 10 80       	mov    $0x80104775,%edx
80104037:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010403a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010403d:	c9                   	leave
8010403e:	c3                   	ret

8010403f <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010403f:	55                   	push   %ebp
80104040:	89 e5                	mov    %esp,%ebp
80104042:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104045:	e8 f1 fe ff ff       	call   80103f3b <allocproc>
8010404a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010404d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104050:	a3 74 92 11 80       	mov    %eax,0x80119274
  if((p->pgdir = setupkvm()) == 0){
80104055:	e8 b8 37 00 00       	call   80107812 <setupkvm>
8010405a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010405d:	89 42 04             	mov    %eax,0x4(%edx)
80104060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104063:	8b 40 04             	mov    0x4(%eax),%eax
80104066:	85 c0                	test   %eax,%eax
80104068:	75 0d                	jne    80104077 <userinit+0x38>
    panic("userinit: out of memory?");
8010406a:	83 ec 0c             	sub    $0xc,%esp
8010406d:	68 52 a7 10 80       	push   $0x8010a752
80104072:	e8 32 c5 ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104077:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010407c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010407f:	8b 40 04             	mov    0x4(%eax),%eax
80104082:	83 ec 04             	sub    $0x4,%esp
80104085:	52                   	push   %edx
80104086:	68 ec f4 10 80       	push   $0x8010f4ec
8010408b:	50                   	push   %eax
8010408c:	e8 3e 3a 00 00       	call   80107acf <inituvm>
80104091:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104097:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a0:	8b 40 18             	mov    0x18(%eax),%eax
801040a3:	83 ec 04             	sub    $0x4,%esp
801040a6:	6a 4c                	push   $0x4c
801040a8:	6a 00                	push   $0x0
801040aa:	50                   	push   %eax
801040ab:	e8 cd 0d 00 00       	call   80104e7d <memset>
801040b0:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801040b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b6:	8b 40 18             	mov    0x18(%eax),%eax
801040b9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801040bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c2:	8b 40 18             	mov    0x18(%eax),%eax
801040c5:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801040cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ce:	8b 50 18             	mov    0x18(%eax),%edx
801040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d4:	8b 40 18             	mov    0x18(%eax),%eax
801040d7:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040db:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801040df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e2:	8b 50 18             	mov    0x18(%eax),%edx
801040e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e8:	8b 40 18             	mov    0x18(%eax),%eax
801040eb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801040ef:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801040f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f6:	8b 40 18             	mov    0x18(%eax),%eax
801040f9:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104103:	8b 40 18             	mov    0x18(%eax),%eax
80104106:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010410d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104110:	8b 40 18             	mov    0x18(%eax),%eax
80104113:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010411a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411d:	83 c0 6c             	add    $0x6c,%eax
80104120:	83 ec 04             	sub    $0x4,%esp
80104123:	6a 10                	push   $0x10
80104125:	68 6b a7 10 80       	push   $0x8010a76b
8010412a:	50                   	push   %eax
8010412b:	e8 50 0f 00 00       	call   80105080 <safestrcpy>
80104130:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104133:	83 ec 0c             	sub    $0xc,%esp
80104136:	68 74 a7 10 80       	push   $0x8010a774
8010413b:	e8 e5 e3 ff ff       	call   80102525 <namei>
80104140:	83 c4 10             	add    $0x10,%esp
80104143:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104146:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104149:	83 ec 0c             	sub    $0xc,%esp
8010414c:	68 40 72 11 80       	push   $0x80117240
80104151:	e8 b1 0a 00 00       	call   80104c07 <acquire>
80104156:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104163:	83 ec 0c             	sub    $0xc,%esp
80104166:	68 40 72 11 80       	push   $0x80117240
8010416b:	e8 05 0b 00 00       	call   80104c75 <release>
80104170:	83 c4 10             	add    $0x10,%esp
}
80104173:	90                   	nop
80104174:	c9                   	leave
80104175:	c3                   	ret

80104176 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104176:	55                   	push   %ebp
80104177:	89 e5                	mov    %esp,%ebp
80104179:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
8010417c:	e8 91 fd ff ff       	call   80103f12 <myproc>
80104181:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104184:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104187:	8b 00                	mov    (%eax),%eax
80104189:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010418c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104190:	7e 2e                	jle    801041c0 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104192:	8b 55 08             	mov    0x8(%ebp),%edx
80104195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104198:	01 c2                	add    %eax,%edx
8010419a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010419d:	8b 40 04             	mov    0x4(%eax),%eax
801041a0:	83 ec 04             	sub    $0x4,%esp
801041a3:	52                   	push   %edx
801041a4:	ff 75 f4             	push   -0xc(%ebp)
801041a7:	50                   	push   %eax
801041a8:	e8 5f 3a 00 00       	call   80107c0c <allocuvm>
801041ad:	83 c4 10             	add    $0x10,%esp
801041b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041b7:	75 3b                	jne    801041f4 <growproc+0x7e>
      return -1;
801041b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041be:	eb 4f                	jmp    8010420f <growproc+0x99>
  } else if(n < 0){
801041c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801041c4:	79 2e                	jns    801041f4 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801041c6:	8b 55 08             	mov    0x8(%ebp),%edx
801041c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041cc:	01 c2                	add    %eax,%edx
801041ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041d1:	8b 40 04             	mov    0x4(%eax),%eax
801041d4:	83 ec 04             	sub    $0x4,%esp
801041d7:	52                   	push   %edx
801041d8:	ff 75 f4             	push   -0xc(%ebp)
801041db:	50                   	push   %eax
801041dc:	e8 30 3b 00 00       	call   80107d11 <deallocuvm>
801041e1:	83 c4 10             	add    $0x10,%esp
801041e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041eb:	75 07                	jne    801041f4 <growproc+0x7e>
      return -1;
801041ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041f2:	eb 1b                	jmp    8010420f <growproc+0x99>
  }
  curproc->sz = sz;
801041f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fa:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801041fc:	83 ec 0c             	sub    $0xc,%esp
801041ff:	ff 75 f0             	push   -0x10(%ebp)
80104202:	e8 29 37 00 00       	call   80107930 <switchuvm>
80104207:	83 c4 10             	add    $0x10,%esp
  return 0;
8010420a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010420f:	c9                   	leave
80104210:	c3                   	ret

80104211 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104211:	55                   	push   %ebp
80104212:	89 e5                	mov    %esp,%ebp
80104214:	57                   	push   %edi
80104215:	56                   	push   %esi
80104216:	53                   	push   %ebx
80104217:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010421a:	e8 f3 fc ff ff       	call   80103f12 <myproc>
8010421f:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104222:	e8 14 fd ff ff       	call   80103f3b <allocproc>
80104227:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010422a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010422e:	75 0a                	jne    8010423a <fork+0x29>
    return -1;
80104230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104235:	e9 48 01 00 00       	jmp    80104382 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010423a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010423d:	8b 10                	mov    (%eax),%edx
8010423f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104242:	8b 40 04             	mov    0x4(%eax),%eax
80104245:	83 ec 08             	sub    $0x8,%esp
80104248:	52                   	push   %edx
80104249:	50                   	push   %eax
8010424a:	e8 60 3c 00 00       	call   80107eaf <copyuvm>
8010424f:	83 c4 10             	add    $0x10,%esp
80104252:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104255:	89 42 04             	mov    %eax,0x4(%edx)
80104258:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010425b:	8b 40 04             	mov    0x4(%eax),%eax
8010425e:	85 c0                	test   %eax,%eax
80104260:	75 30                	jne    80104292 <fork+0x81>
    kfree(np->kstack);
80104262:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104265:	8b 40 08             	mov    0x8(%eax),%eax
80104268:	83 ec 0c             	sub    $0xc,%esp
8010426b:	50                   	push   %eax
8010426c:	e8 7f e9 ff ff       	call   80102bf0 <kfree>
80104271:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104274:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104277:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010427e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104281:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428d:	e9 f0 00 00 00       	jmp    80104382 <fork+0x171>
  }
  np->sz = curproc->sz;
80104292:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104295:	8b 10                	mov    (%eax),%edx
80104297:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010429a:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010429c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010429f:	8b 55 e0             	mov    -0x20(%ebp),%edx
801042a2:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801042a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042a8:	8b 48 18             	mov    0x18(%eax),%ecx
801042ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042ae:	8b 40 18             	mov    0x18(%eax),%eax
801042b1:	89 c2                	mov    %eax,%edx
801042b3:	89 cb                	mov    %ecx,%ebx
801042b5:	b8 13 00 00 00       	mov    $0x13,%eax
801042ba:	89 d7                	mov    %edx,%edi
801042bc:	89 de                	mov    %ebx,%esi
801042be:	89 c1                	mov    %eax,%ecx
801042c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801042c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801042c5:	8b 40 18             	mov    0x18(%eax),%eax
801042c8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801042cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801042d6:	eb 3b                	jmp    80104313 <fork+0x102>
    if(curproc->ofile[i])
801042d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042de:	83 c2 08             	add    $0x8,%edx
801042e1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042e5:	85 c0                	test   %eax,%eax
801042e7:	74 26                	je     8010430f <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
801042e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801042ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801042ef:	83 c2 08             	add    $0x8,%edx
801042f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801042f6:	83 ec 0c             	sub    $0xc,%esp
801042f9:	50                   	push   %eax
801042fa:	e8 55 cd ff ff       	call   80101054 <filedup>
801042ff:	83 c4 10             	add    $0x10,%esp
80104302:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104305:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104308:	83 c1 08             	add    $0x8,%ecx
8010430b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
8010430f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104313:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104317:	7e bf                	jle    801042d8 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80104319:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010431c:	8b 40 68             	mov    0x68(%eax),%eax
8010431f:	83 ec 0c             	sub    $0xc,%esp
80104322:	50                   	push   %eax
80104323:	e8 90 d6 ff ff       	call   801019b8 <idup>
80104328:	83 c4 10             	add    $0x10,%esp
8010432b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010432e:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104331:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104334:	8d 50 6c             	lea    0x6c(%eax),%edx
80104337:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010433a:	83 c0 6c             	add    $0x6c,%eax
8010433d:	83 ec 04             	sub    $0x4,%esp
80104340:	6a 10                	push   $0x10
80104342:	52                   	push   %edx
80104343:	50                   	push   %eax
80104344:	e8 37 0d 00 00       	call   80105080 <safestrcpy>
80104349:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
8010434c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010434f:	8b 40 10             	mov    0x10(%eax),%eax
80104352:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104355:	83 ec 0c             	sub    $0xc,%esp
80104358:	68 40 72 11 80       	push   $0x80117240
8010435d:	e8 a5 08 00 00       	call   80104c07 <acquire>
80104362:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80104365:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104368:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010436f:	83 ec 0c             	sub    $0xc,%esp
80104372:	68 40 72 11 80       	push   $0x80117240
80104377:	e8 f9 08 00 00       	call   80104c75 <release>
8010437c:	83 c4 10             	add    $0x10,%esp

  return pid;
8010437f:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104382:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104385:	5b                   	pop    %ebx
80104386:	5e                   	pop    %esi
80104387:	5f                   	pop    %edi
80104388:	5d                   	pop    %ebp
80104389:	c3                   	ret

8010438a <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010438a:	55                   	push   %ebp
8010438b:	89 e5                	mov    %esp,%ebp
8010438d:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104390:	e8 7d fb ff ff       	call   80103f12 <myproc>
80104395:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104398:	a1 74 92 11 80       	mov    0x80119274,%eax
8010439d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801043a0:	75 0d                	jne    801043af <exit+0x25>
    panic("init exiting");
801043a2:	83 ec 0c             	sub    $0xc,%esp
801043a5:	68 76 a7 10 80       	push   $0x8010a776
801043aa:	e8 fa c1 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801043af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801043b6:	eb 3f                	jmp    801043f7 <exit+0x6d>
    if(curproc->ofile[fd]){
801043b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043be:	83 c2 08             	add    $0x8,%edx
801043c1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043c5:	85 c0                	test   %eax,%eax
801043c7:	74 2a                	je     801043f3 <exit+0x69>
      fileclose(curproc->ofile[fd]);
801043c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043cf:	83 c2 08             	add    $0x8,%edx
801043d2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043d6:	83 ec 0c             	sub    $0xc,%esp
801043d9:	50                   	push   %eax
801043da:	e8 c6 cc ff ff       	call   801010a5 <fileclose>
801043df:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
801043e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043e8:	83 c2 08             	add    $0x8,%edx
801043eb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801043f2:	00 
  for(fd = 0; fd < NOFILE; fd++){
801043f3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801043f7:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801043fb:	7e bb                	jle    801043b8 <exit+0x2e>
    }
  }

  begin_op();
801043fd:	e8 1e f1 ff ff       	call   80103520 <begin_op>
  iput(curproc->cwd);
80104402:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104405:	8b 40 68             	mov    0x68(%eax),%eax
80104408:	83 ec 0c             	sub    $0xc,%esp
8010440b:	50                   	push   %eax
8010440c:	e8 42 d7 ff ff       	call   80101b53 <iput>
80104411:	83 c4 10             	add    $0x10,%esp
  end_op();
80104414:	e8 93 f1 ff ff       	call   801035ac <end_op>
  curproc->cwd = 0;
80104419:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010441c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104423:	83 ec 0c             	sub    $0xc,%esp
80104426:	68 40 72 11 80       	push   $0x80117240
8010442b:	e8 d7 07 00 00       	call   80104c07 <acquire>
80104430:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104433:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104436:	8b 40 14             	mov    0x14(%eax),%eax
80104439:	83 ec 0c             	sub    $0xc,%esp
8010443c:	50                   	push   %eax
8010443d:	e8 20 04 00 00       	call   80104862 <wakeup1>
80104442:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104445:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
8010444c:	eb 37                	jmp    80104485 <exit+0xfb>
    if(p->parent == curproc){
8010444e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104451:	8b 40 14             	mov    0x14(%eax),%eax
80104454:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104457:	75 28                	jne    80104481 <exit+0xf7>
      p->parent = initproc;
80104459:	8b 15 74 92 11 80    	mov    0x80119274,%edx
8010445f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104462:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104468:	8b 40 0c             	mov    0xc(%eax),%eax
8010446b:	83 f8 05             	cmp    $0x5,%eax
8010446e:	75 11                	jne    80104481 <exit+0xf7>
        wakeup1(initproc);
80104470:	a1 74 92 11 80       	mov    0x80119274,%eax
80104475:	83 ec 0c             	sub    $0xc,%esp
80104478:	50                   	push   %eax
80104479:	e8 e4 03 00 00       	call   80104862 <wakeup1>
8010447e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104481:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104485:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
8010448c:	72 c0                	jb     8010444e <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010448e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104491:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104498:	e8 e5 01 00 00       	call   80104682 <sched>
  panic("zombie exit");
8010449d:	83 ec 0c             	sub    $0xc,%esp
801044a0:	68 83 a7 10 80       	push   $0x8010a783
801044a5:	e8 ff c0 ff ff       	call   801005a9 <panic>

801044aa <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801044aa:	55                   	push   %ebp
801044ab:	89 e5                	mov    %esp,%ebp
801044ad:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801044b0:	e8 5d fa ff ff       	call   80103f12 <myproc>
801044b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801044b8:	83 ec 0c             	sub    $0xc,%esp
801044bb:	68 40 72 11 80       	push   $0x80117240
801044c0:	e8 42 07 00 00       	call   80104c07 <acquire>
801044c5:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801044c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044cf:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801044d6:	e9 a1 00 00 00       	jmp    8010457c <wait+0xd2>
      if(p->parent != curproc)
801044db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044de:	8b 40 14             	mov    0x14(%eax),%eax
801044e1:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801044e4:	0f 85 8d 00 00 00    	jne    80104577 <wait+0xcd>
        continue;
      havekids = 1;
801044ea:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801044f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f4:	8b 40 0c             	mov    0xc(%eax),%eax
801044f7:	83 f8 05             	cmp    $0x5,%eax
801044fa:	75 7c                	jne    80104578 <wait+0xce>
        // Found one.
        pid = p->pid;
801044fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ff:	8b 40 10             	mov    0x10(%eax),%eax
80104502:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104508:	8b 40 08             	mov    0x8(%eax),%eax
8010450b:	83 ec 0c             	sub    $0xc,%esp
8010450e:	50                   	push   %eax
8010450f:	e8 dc e6 ff ff       	call   80102bf0 <kfree>
80104514:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104524:	8b 40 04             	mov    0x4(%eax),%eax
80104527:	83 ec 0c             	sub    $0xc,%esp
8010452a:	50                   	push   %eax
8010452b:	e8 a5 38 00 00       	call   80107dd5 <freevm>
80104530:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104536:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010453d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104540:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010454e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104551:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104558:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104562:	83 ec 0c             	sub    $0xc,%esp
80104565:	68 40 72 11 80       	push   $0x80117240
8010456a:	e8 06 07 00 00       	call   80104c75 <release>
8010456f:	83 c4 10             	add    $0x10,%esp
        return pid;
80104572:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104575:	eb 51                	jmp    801045c8 <wait+0x11e>
        continue;
80104577:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104578:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010457c:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104583:	0f 82 52 ff ff ff    	jb     801044db <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104589:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010458d:	74 0a                	je     80104599 <wait+0xef>
8010458f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104592:	8b 40 24             	mov    0x24(%eax),%eax
80104595:	85 c0                	test   %eax,%eax
80104597:	74 17                	je     801045b0 <wait+0x106>
      release(&ptable.lock);
80104599:	83 ec 0c             	sub    $0xc,%esp
8010459c:	68 40 72 11 80       	push   $0x80117240
801045a1:	e8 cf 06 00 00       	call   80104c75 <release>
801045a6:	83 c4 10             	add    $0x10,%esp
      return -1;
801045a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ae:	eb 18                	jmp    801045c8 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801045b0:	83 ec 08             	sub    $0x8,%esp
801045b3:	68 40 72 11 80       	push   $0x80117240
801045b8:	ff 75 ec             	push   -0x14(%ebp)
801045bb:	e8 fb 01 00 00       	call   801047bb <sleep>
801045c0:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045c3:	e9 00 ff ff ff       	jmp    801044c8 <wait+0x1e>
  }
}
801045c8:	c9                   	leave
801045c9:	c3                   	ret

801045ca <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801045ca:	55                   	push   %ebp
801045cb:	89 e5                	mov    %esp,%ebp
801045cd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801045d0:	e8 c5 f8 ff ff       	call   80103e9a <mycpu>
801045d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801045d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045db:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801045e2:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801045e5:	e8 70 f8 ff ff       	call   80103e5a <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801045ea:	83 ec 0c             	sub    $0xc,%esp
801045ed:	68 40 72 11 80       	push   $0x80117240
801045f2:	e8 10 06 00 00       	call   80104c07 <acquire>
801045f7:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045fa:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
80104601:	eb 61                	jmp    80104664 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104606:	8b 40 0c             	mov    0xc(%eax),%eax
80104609:	83 f8 03             	cmp    $0x3,%eax
8010460c:	75 51                	jne    8010465f <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010460e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104614:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010461a:	83 ec 0c             	sub    $0xc,%esp
8010461d:	ff 75 f4             	push   -0xc(%ebp)
80104620:	e8 0b 33 00 00       	call   80107930 <switchuvm>
80104625:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462b:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104635:	8b 40 1c             	mov    0x1c(%eax),%eax
80104638:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010463b:	83 c2 04             	add    $0x4,%edx
8010463e:	83 ec 08             	sub    $0x8,%esp
80104641:	50                   	push   %eax
80104642:	52                   	push   %edx
80104643:	e8 aa 0a 00 00       	call   801050f2 <swtch>
80104648:	83 c4 10             	add    $0x10,%esp
      switchkvm();
8010464b:	e8 c7 32 00 00       	call   80107917 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104650:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104653:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010465a:	00 00 00 
8010465d:	eb 01                	jmp    80104660 <scheduler+0x96>
        continue;
8010465f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104660:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104664:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
8010466b:	72 96                	jb     80104603 <scheduler+0x39>
    }
    release(&ptable.lock);
8010466d:	83 ec 0c             	sub    $0xc,%esp
80104670:	68 40 72 11 80       	push   $0x80117240
80104675:	e8 fb 05 00 00       	call   80104c75 <release>
8010467a:	83 c4 10             	add    $0x10,%esp
    sti();
8010467d:	e9 63 ff ff ff       	jmp    801045e5 <scheduler+0x1b>

80104682 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104682:	55                   	push   %ebp
80104683:	89 e5                	mov    %esp,%ebp
80104685:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104688:	e8 85 f8 ff ff       	call   80103f12 <myproc>
8010468d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104690:	83 ec 0c             	sub    $0xc,%esp
80104693:	68 40 72 11 80       	push   $0x80117240
80104698:	e8 a5 06 00 00       	call   80104d42 <holding>
8010469d:	83 c4 10             	add    $0x10,%esp
801046a0:	85 c0                	test   %eax,%eax
801046a2:	75 0d                	jne    801046b1 <sched+0x2f>
    panic("sched ptable.lock");
801046a4:	83 ec 0c             	sub    $0xc,%esp
801046a7:	68 8f a7 10 80       	push   $0x8010a78f
801046ac:	e8 f8 be ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801046b1:	e8 e4 f7 ff ff       	call   80103e9a <mycpu>
801046b6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801046bc:	83 f8 01             	cmp    $0x1,%eax
801046bf:	74 0d                	je     801046ce <sched+0x4c>
    panic("sched locks");
801046c1:	83 ec 0c             	sub    $0xc,%esp
801046c4:	68 a1 a7 10 80       	push   $0x8010a7a1
801046c9:	e8 db be ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801046ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d1:	8b 40 0c             	mov    0xc(%eax),%eax
801046d4:	83 f8 04             	cmp    $0x4,%eax
801046d7:	75 0d                	jne    801046e6 <sched+0x64>
    panic("sched running");
801046d9:	83 ec 0c             	sub    $0xc,%esp
801046dc:	68 ad a7 10 80       	push   $0x8010a7ad
801046e1:	e8 c3 be ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
801046e6:	e8 5f f7 ff ff       	call   80103e4a <readeflags>
801046eb:	25 00 02 00 00       	and    $0x200,%eax
801046f0:	85 c0                	test   %eax,%eax
801046f2:	74 0d                	je     80104701 <sched+0x7f>
    panic("sched interruptible");
801046f4:	83 ec 0c             	sub    $0xc,%esp
801046f7:	68 bb a7 10 80       	push   $0x8010a7bb
801046fc:	e8 a8 be ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104701:	e8 94 f7 ff ff       	call   80103e9a <mycpu>
80104706:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010470c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010470f:	e8 86 f7 ff ff       	call   80103e9a <mycpu>
80104714:	8b 40 04             	mov    0x4(%eax),%eax
80104717:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471a:	83 c2 1c             	add    $0x1c,%edx
8010471d:	83 ec 08             	sub    $0x8,%esp
80104720:	50                   	push   %eax
80104721:	52                   	push   %edx
80104722:	e8 cb 09 00 00       	call   801050f2 <swtch>
80104727:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
8010472a:	e8 6b f7 ff ff       	call   80103e9a <mycpu>
8010472f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104732:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104738:	90                   	nop
80104739:	c9                   	leave
8010473a:	c3                   	ret

8010473b <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010473b:	55                   	push   %ebp
8010473c:	89 e5                	mov    %esp,%ebp
8010473e:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104741:	83 ec 0c             	sub    $0xc,%esp
80104744:	68 40 72 11 80       	push   $0x80117240
80104749:	e8 b9 04 00 00       	call   80104c07 <acquire>
8010474e:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104751:	e8 bc f7 ff ff       	call   80103f12 <myproc>
80104756:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010475d:	e8 20 ff ff ff       	call   80104682 <sched>
  release(&ptable.lock);
80104762:	83 ec 0c             	sub    $0xc,%esp
80104765:	68 40 72 11 80       	push   $0x80117240
8010476a:	e8 06 05 00 00       	call   80104c75 <release>
8010476f:	83 c4 10             	add    $0x10,%esp
}
80104772:	90                   	nop
80104773:	c9                   	leave
80104774:	c3                   	ret

80104775 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104775:	55                   	push   %ebp
80104776:	89 e5                	mov    %esp,%ebp
80104778:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010477b:	83 ec 0c             	sub    $0xc,%esp
8010477e:	68 40 72 11 80       	push   $0x80117240
80104783:	e8 ed 04 00 00       	call   80104c75 <release>
80104788:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010478b:	a1 04 f0 10 80       	mov    0x8010f004,%eax
80104790:	85 c0                	test   %eax,%eax
80104792:	74 24                	je     801047b8 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104794:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
8010479b:	00 00 00 
    iinit(ROOTDEV);
8010479e:	83 ec 0c             	sub    $0xc,%esp
801047a1:	6a 01                	push   $0x1
801047a3:	e8 d9 ce ff ff       	call   80101681 <iinit>
801047a8:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801047ab:	83 ec 0c             	sub    $0xc,%esp
801047ae:	6a 01                	push   $0x1
801047b0:	e8 4c eb ff ff       	call   80103301 <initlog>
801047b5:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801047b8:	90                   	nop
801047b9:	c9                   	leave
801047ba:	c3                   	ret

801047bb <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801047bb:	55                   	push   %ebp
801047bc:	89 e5                	mov    %esp,%ebp
801047be:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801047c1:	e8 4c f7 ff ff       	call   80103f12 <myproc>
801047c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801047c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047cd:	75 0d                	jne    801047dc <sleep+0x21>
    panic("sleep");
801047cf:	83 ec 0c             	sub    $0xc,%esp
801047d2:	68 cf a7 10 80       	push   $0x8010a7cf
801047d7:	e8 cd bd ff ff       	call   801005a9 <panic>

  if(lk == 0)
801047dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801047e0:	75 0d                	jne    801047ef <sleep+0x34>
    panic("sleep without lk");
801047e2:	83 ec 0c             	sub    $0xc,%esp
801047e5:	68 d5 a7 10 80       	push   $0x8010a7d5
801047ea:	e8 ba bd ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801047ef:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
801047f6:	74 1e                	je     80104816 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
801047f8:	83 ec 0c             	sub    $0xc,%esp
801047fb:	68 40 72 11 80       	push   $0x80117240
80104800:	e8 02 04 00 00       	call   80104c07 <acquire>
80104805:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104808:	83 ec 0c             	sub    $0xc,%esp
8010480b:	ff 75 0c             	push   0xc(%ebp)
8010480e:	e8 62 04 00 00       	call   80104c75 <release>
80104813:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104819:	8b 55 08             	mov    0x8(%ebp),%edx
8010481c:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104822:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104829:	e8 54 fe ff ff       	call   80104682 <sched>

  // Tidy up.
  p->chan = 0;
8010482e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104831:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104838:	81 7d 0c 40 72 11 80 	cmpl   $0x80117240,0xc(%ebp)
8010483f:	74 1e                	je     8010485f <sleep+0xa4>
    release(&ptable.lock);
80104841:	83 ec 0c             	sub    $0xc,%esp
80104844:	68 40 72 11 80       	push   $0x80117240
80104849:	e8 27 04 00 00       	call   80104c75 <release>
8010484e:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104851:	83 ec 0c             	sub    $0xc,%esp
80104854:	ff 75 0c             	push   0xc(%ebp)
80104857:	e8 ab 03 00 00       	call   80104c07 <acquire>
8010485c:	83 c4 10             	add    $0x10,%esp
  }
}
8010485f:	90                   	nop
80104860:	c9                   	leave
80104861:	c3                   	ret

80104862 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104862:	55                   	push   %ebp
80104863:	89 e5                	mov    %esp,%ebp
80104865:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104868:	c7 45 fc 74 72 11 80 	movl   $0x80117274,-0x4(%ebp)
8010486f:	eb 24                	jmp    80104895 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104871:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104874:	8b 40 0c             	mov    0xc(%eax),%eax
80104877:	83 f8 02             	cmp    $0x2,%eax
8010487a:	75 15                	jne    80104891 <wakeup1+0x2f>
8010487c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010487f:	8b 40 20             	mov    0x20(%eax),%eax
80104882:	39 45 08             	cmp    %eax,0x8(%ebp)
80104885:	75 0a                	jne    80104891 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104887:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010488a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104891:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104895:	81 7d fc 74 92 11 80 	cmpl   $0x80119274,-0x4(%ebp)
8010489c:	72 d3                	jb     80104871 <wakeup1+0xf>
}
8010489e:	90                   	nop
8010489f:	90                   	nop
801048a0:	c9                   	leave
801048a1:	c3                   	ret

801048a2 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048a2:	55                   	push   %ebp
801048a3:	89 e5                	mov    %esp,%ebp
801048a5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801048a8:	83 ec 0c             	sub    $0xc,%esp
801048ab:	68 40 72 11 80       	push   $0x80117240
801048b0:	e8 52 03 00 00       	call   80104c07 <acquire>
801048b5:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801048b8:	83 ec 0c             	sub    $0xc,%esp
801048bb:	ff 75 08             	push   0x8(%ebp)
801048be:	e8 9f ff ff ff       	call   80104862 <wakeup1>
801048c3:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801048c6:	83 ec 0c             	sub    $0xc,%esp
801048c9:	68 40 72 11 80       	push   $0x80117240
801048ce:	e8 a2 03 00 00       	call   80104c75 <release>
801048d3:	83 c4 10             	add    $0x10,%esp
}
801048d6:	90                   	nop
801048d7:	c9                   	leave
801048d8:	c3                   	ret

801048d9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801048d9:	55                   	push   %ebp
801048da:	89 e5                	mov    %esp,%ebp
801048dc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801048df:	83 ec 0c             	sub    $0xc,%esp
801048e2:	68 40 72 11 80       	push   $0x80117240
801048e7:	e8 1b 03 00 00       	call   80104c07 <acquire>
801048ec:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048ef:	c7 45 f4 74 72 11 80 	movl   $0x80117274,-0xc(%ebp)
801048f6:	eb 45                	jmp    8010493d <kill+0x64>
    if(p->pid == pid){
801048f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fb:	8b 40 10             	mov    0x10(%eax),%eax
801048fe:	39 45 08             	cmp    %eax,0x8(%ebp)
80104901:	75 36                	jne    80104939 <kill+0x60>
      p->killed = 1;
80104903:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104906:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010490d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104910:	8b 40 0c             	mov    0xc(%eax),%eax
80104913:	83 f8 02             	cmp    $0x2,%eax
80104916:	75 0a                	jne    80104922 <kill+0x49>
        p->state = RUNNABLE;
80104918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104922:	83 ec 0c             	sub    $0xc,%esp
80104925:	68 40 72 11 80       	push   $0x80117240
8010492a:	e8 46 03 00 00       	call   80104c75 <release>
8010492f:	83 c4 10             	add    $0x10,%esp
      return 0;
80104932:	b8 00 00 00 00       	mov    $0x0,%eax
80104937:	eb 22                	jmp    8010495b <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104939:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010493d:	81 7d f4 74 92 11 80 	cmpl   $0x80119274,-0xc(%ebp)
80104944:	72 b2                	jb     801048f8 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104946:	83 ec 0c             	sub    $0xc,%esp
80104949:	68 40 72 11 80       	push   $0x80117240
8010494e:	e8 22 03 00 00       	call   80104c75 <release>
80104953:	83 c4 10             	add    $0x10,%esp
  return -1;
80104956:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010495b:	c9                   	leave
8010495c:	c3                   	ret

8010495d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010495d:	55                   	push   %ebp
8010495e:	89 e5                	mov    %esp,%ebp
80104960:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104963:	c7 45 f0 74 72 11 80 	movl   $0x80117274,-0x10(%ebp)
8010496a:	e9 d7 00 00 00       	jmp    80104a46 <procdump+0xe9>
    if(p->state == UNUSED)
8010496f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104972:	8b 40 0c             	mov    0xc(%eax),%eax
80104975:	85 c0                	test   %eax,%eax
80104977:	0f 84 c4 00 00 00    	je     80104a41 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010497d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104980:	8b 40 0c             	mov    0xc(%eax),%eax
80104983:	83 f8 05             	cmp    $0x5,%eax
80104986:	77 23                	ja     801049ab <procdump+0x4e>
80104988:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010498b:	8b 40 0c             	mov    0xc(%eax),%eax
8010498e:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
80104995:	85 c0                	test   %eax,%eax
80104997:	74 12                	je     801049ab <procdump+0x4e>
      state = states[p->state];
80104999:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499c:	8b 40 0c             	mov    0xc(%eax),%eax
8010499f:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801049a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049a9:	eb 07                	jmp    801049b2 <procdump+0x55>
    else
      state = "???";
801049ab:	c7 45 ec e6 a7 10 80 	movl   $0x8010a7e6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b5:	8d 50 6c             	lea    0x6c(%eax),%edx
801049b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049bb:	8b 40 10             	mov    0x10(%eax),%eax
801049be:	52                   	push   %edx
801049bf:	ff 75 ec             	push   -0x14(%ebp)
801049c2:	50                   	push   %eax
801049c3:	68 ea a7 10 80       	push   $0x8010a7ea
801049c8:	e8 27 ba ff ff       	call   801003f4 <cprintf>
801049cd:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801049d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049d3:	8b 40 0c             	mov    0xc(%eax),%eax
801049d6:	83 f8 02             	cmp    $0x2,%eax
801049d9:	75 54                	jne    80104a2f <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801049db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049de:	8b 40 1c             	mov    0x1c(%eax),%eax
801049e1:	8b 40 0c             	mov    0xc(%eax),%eax
801049e4:	83 c0 08             	add    $0x8,%eax
801049e7:	89 c2                	mov    %eax,%edx
801049e9:	83 ec 08             	sub    $0x8,%esp
801049ec:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049ef:	50                   	push   %eax
801049f0:	52                   	push   %edx
801049f1:	e8 d1 02 00 00       	call   80104cc7 <getcallerpcs>
801049f6:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801049f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a00:	eb 1c                	jmp    80104a1e <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a05:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a09:	83 ec 08             	sub    $0x8,%esp
80104a0c:	50                   	push   %eax
80104a0d:	68 f3 a7 10 80       	push   $0x8010a7f3
80104a12:	e8 dd b9 ff ff       	call   801003f4 <cprintf>
80104a17:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104a1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104a1e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a22:	7f 0b                	jg     80104a2f <procdump+0xd2>
80104a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a27:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a2b:	85 c0                	test   %eax,%eax
80104a2d:	75 d3                	jne    80104a02 <procdump+0xa5>
    }
    cprintf("\n");
80104a2f:	83 ec 0c             	sub    $0xc,%esp
80104a32:	68 f7 a7 10 80       	push   $0x8010a7f7
80104a37:	e8 b8 b9 ff ff       	call   801003f4 <cprintf>
80104a3c:	83 c4 10             	add    $0x10,%esp
80104a3f:	eb 01                	jmp    80104a42 <procdump+0xe5>
      continue;
80104a41:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a42:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104a46:	81 7d f0 74 92 11 80 	cmpl   $0x80119274,-0x10(%ebp)
80104a4d:	0f 82 1c ff ff ff    	jb     8010496f <procdump+0x12>
  }
}
80104a53:	90                   	nop
80104a54:	90                   	nop
80104a55:	c9                   	leave
80104a56:	c3                   	ret

80104a57 <uthread_init>:

int
uthread_init(int address)
{
80104a57:	55                   	push   %ebp
80104a58:	89 e5                	mov    %esp,%ebp
80104a5a:	83 ec 18             	sub    $0x18,%esp
  struct proc *cur_proc = myproc();
80104a5d:	e8 b0 f4 ff ff       	call   80103f12 <myproc>
80104a62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("uthread_init: setting scheduler to %x\n", address);
80104a65:	83 ec 08             	sub    $0x8,%esp
80104a68:	ff 75 08             	push   0x8(%ebp)
80104a6b:	68 fc a7 10 80       	push   $0x8010a7fc
80104a70:	e8 7f b9 ff ff       	call   801003f4 <cprintf>
80104a75:	83 c4 10             	add    $0x10,%esp
  cur_proc->scheduler = address;
80104a78:	8b 55 08             	mov    0x8(%ebp),%edx
80104a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7e:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
80104a81:	b8 00 00 00 00       	mov    $0x0,%eax
80104a86:	c9                   	leave
80104a87:	c3                   	ret

80104a88 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104a88:	55                   	push   %ebp
80104a89:	89 e5                	mov    %esp,%ebp
80104a8b:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104a8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104a91:	83 c0 04             	add    $0x4,%eax
80104a94:	83 ec 08             	sub    $0x8,%esp
80104a97:	68 4d a8 10 80       	push   $0x8010a84d
80104a9c:	50                   	push   %eax
80104a9d:	e8 43 01 00 00       	call   80104be5 <initlock>
80104aa2:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80104aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80104aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
80104aab:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80104aae:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80104aba:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80104ac1:	90                   	nop
80104ac2:	c9                   	leave
80104ac3:	c3                   	ret

80104ac4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104ac4:	55                   	push   %ebp
80104ac5:	89 e5                	mov    %esp,%ebp
80104ac7:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104aca:	8b 45 08             	mov    0x8(%ebp),%eax
80104acd:	83 c0 04             	add    $0x4,%eax
80104ad0:	83 ec 0c             	sub    $0xc,%esp
80104ad3:	50                   	push   %eax
80104ad4:	e8 2e 01 00 00       	call   80104c07 <acquire>
80104ad9:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104adc:	eb 15                	jmp    80104af3 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
80104ade:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae1:	83 c0 04             	add    $0x4,%eax
80104ae4:	83 ec 08             	sub    $0x8,%esp
80104ae7:	50                   	push   %eax
80104ae8:	ff 75 08             	push   0x8(%ebp)
80104aeb:	e8 cb fc ff ff       	call   801047bb <sleep>
80104af0:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104af3:	8b 45 08             	mov    0x8(%ebp),%eax
80104af6:	8b 00                	mov    (%eax),%eax
80104af8:	85 c0                	test   %eax,%eax
80104afa:	75 e2                	jne    80104ade <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104afc:	8b 45 08             	mov    0x8(%ebp),%eax
80104aff:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104b05:	e8 08 f4 ff ff       	call   80103f12 <myproc>
80104b0a:	8b 50 10             	mov    0x10(%eax),%edx
80104b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b10:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104b13:	8b 45 08             	mov    0x8(%ebp),%eax
80104b16:	83 c0 04             	add    $0x4,%eax
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	50                   	push   %eax
80104b1d:	e8 53 01 00 00       	call   80104c75 <release>
80104b22:	83 c4 10             	add    $0x10,%esp
}
80104b25:	90                   	nop
80104b26:	c9                   	leave
80104b27:	c3                   	ret

80104b28 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104b28:	55                   	push   %ebp
80104b29:	89 e5                	mov    %esp,%ebp
80104b2b:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b31:	83 c0 04             	add    $0x4,%eax
80104b34:	83 ec 0c             	sub    $0xc,%esp
80104b37:	50                   	push   %eax
80104b38:	e8 ca 00 00 00       	call   80104c07 <acquire>
80104b3d:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104b40:	8b 45 08             	mov    0x8(%ebp),%eax
80104b43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104b49:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104b53:	83 ec 0c             	sub    $0xc,%esp
80104b56:	ff 75 08             	push   0x8(%ebp)
80104b59:	e8 44 fd ff ff       	call   801048a2 <wakeup>
80104b5e:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104b61:	8b 45 08             	mov    0x8(%ebp),%eax
80104b64:	83 c0 04             	add    $0x4,%eax
80104b67:	83 ec 0c             	sub    $0xc,%esp
80104b6a:	50                   	push   %eax
80104b6b:	e8 05 01 00 00       	call   80104c75 <release>
80104b70:	83 c4 10             	add    $0x10,%esp
}
80104b73:	90                   	nop
80104b74:	c9                   	leave
80104b75:	c3                   	ret

80104b76 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104b76:	55                   	push   %ebp
80104b77:	89 e5                	mov    %esp,%ebp
80104b79:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7f:	83 c0 04             	add    $0x4,%eax
80104b82:	83 ec 0c             	sub    $0xc,%esp
80104b85:	50                   	push   %eax
80104b86:	e8 7c 00 00 00       	call   80104c07 <acquire>
80104b8b:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104b91:	8b 00                	mov    (%eax),%eax
80104b93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80104b96:	8b 45 08             	mov    0x8(%ebp),%eax
80104b99:	83 c0 04             	add    $0x4,%eax
80104b9c:	83 ec 0c             	sub    $0xc,%esp
80104b9f:	50                   	push   %eax
80104ba0:	e8 d0 00 00 00       	call   80104c75 <release>
80104ba5:	83 c4 10             	add    $0x10,%esp
  return r;
80104ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104bab:	c9                   	leave
80104bac:	c3                   	ret

80104bad <readeflags>:
{
80104bad:	55                   	push   %ebp
80104bae:	89 e5                	mov    %esp,%ebp
80104bb0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104bb3:	9c                   	pushf
80104bb4:	58                   	pop    %eax
80104bb5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104bb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bbb:	c9                   	leave
80104bbc:	c3                   	ret

80104bbd <cli>:
{
80104bbd:	55                   	push   %ebp
80104bbe:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104bc0:	fa                   	cli
}
80104bc1:	90                   	nop
80104bc2:	5d                   	pop    %ebp
80104bc3:	c3                   	ret

80104bc4 <sti>:
{
80104bc4:	55                   	push   %ebp
80104bc5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104bc7:	fb                   	sti
}
80104bc8:	90                   	nop
80104bc9:	5d                   	pop    %ebp
80104bca:	c3                   	ret

80104bcb <xchg>:
{
80104bcb:	55                   	push   %ebp
80104bcc:	89 e5                	mov    %esp,%ebp
80104bce:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80104bd1:	8b 55 08             	mov    0x8(%ebp),%edx
80104bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104bda:	f0 87 02             	lock xchg %eax,(%edx)
80104bdd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80104be0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104be3:	c9                   	leave
80104be4:	c3                   	ret

80104be5 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104be5:	55                   	push   %ebp
80104be6:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104be8:	8b 45 08             	mov    0x8(%ebp),%eax
80104beb:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bee:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80104bfd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104c04:	90                   	nop
80104c05:	5d                   	pop    %ebp
80104c06:	c3                   	ret

80104c07 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104c07:	55                   	push   %ebp
80104c08:	89 e5                	mov    %esp,%ebp
80104c0a:	53                   	push   %ebx
80104c0b:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104c0e:	e8 5f 01 00 00       	call   80104d72 <pushcli>
  if(holding(lk)){
80104c13:	8b 45 08             	mov    0x8(%ebp),%eax
80104c16:	83 ec 0c             	sub    $0xc,%esp
80104c19:	50                   	push   %eax
80104c1a:	e8 23 01 00 00       	call   80104d42 <holding>
80104c1f:	83 c4 10             	add    $0x10,%esp
80104c22:	85 c0                	test   %eax,%eax
80104c24:	74 0d                	je     80104c33 <acquire+0x2c>
    panic("acquire");
80104c26:	83 ec 0c             	sub    $0xc,%esp
80104c29:	68 58 a8 10 80       	push   $0x8010a858
80104c2e:	e8 76 b9 ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104c33:	90                   	nop
80104c34:	8b 45 08             	mov    0x8(%ebp),%eax
80104c37:	83 ec 08             	sub    $0x8,%esp
80104c3a:	6a 01                	push   $0x1
80104c3c:	50                   	push   %eax
80104c3d:	e8 89 ff ff ff       	call   80104bcb <xchg>
80104c42:	83 c4 10             	add    $0x10,%esp
80104c45:	85 c0                	test   %eax,%eax
80104c47:	75 eb                	jne    80104c34 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104c49:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104c4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104c51:	e8 44 f2 ff ff       	call   80103e9a <mycpu>
80104c56:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104c59:	8b 45 08             	mov    0x8(%ebp),%eax
80104c5c:	83 c0 0c             	add    $0xc,%eax
80104c5f:	83 ec 08             	sub    $0x8,%esp
80104c62:	50                   	push   %eax
80104c63:	8d 45 08             	lea    0x8(%ebp),%eax
80104c66:	50                   	push   %eax
80104c67:	e8 5b 00 00 00       	call   80104cc7 <getcallerpcs>
80104c6c:	83 c4 10             	add    $0x10,%esp
}
80104c6f:	90                   	nop
80104c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c73:	c9                   	leave
80104c74:	c3                   	ret

80104c75 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104c75:	55                   	push   %ebp
80104c76:	89 e5                	mov    %esp,%ebp
80104c78:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80104c7b:	83 ec 0c             	sub    $0xc,%esp
80104c7e:	ff 75 08             	push   0x8(%ebp)
80104c81:	e8 bc 00 00 00       	call   80104d42 <holding>
80104c86:	83 c4 10             	add    $0x10,%esp
80104c89:	85 c0                	test   %eax,%eax
80104c8b:	75 0d                	jne    80104c9a <release+0x25>
    panic("release");
80104c8d:	83 ec 0c             	sub    $0xc,%esp
80104c90:	68 60 a8 10 80       	push   $0x8010a860
80104c95:	e8 0f b9 ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
80104c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c9d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80104cae:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb6:	8b 55 08             	mov    0x8(%ebp),%edx
80104cb9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80104cbf:	e8 fb 00 00 00       	call   80104dbf <popcli>
}
80104cc4:	90                   	nop
80104cc5:	c9                   	leave
80104cc6:	c3                   	ret

80104cc7 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104cc7:	55                   	push   %ebp
80104cc8:	89 e5                	mov    %esp,%ebp
80104cca:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80104ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd0:	83 e8 08             	sub    $0x8,%eax
80104cd3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104cd6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104cdd:	eb 38                	jmp    80104d17 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104cdf:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104ce3:	74 53                	je     80104d38 <getcallerpcs+0x71>
80104ce5:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104cec:	76 4a                	jbe    80104d38 <getcallerpcs+0x71>
80104cee:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104cf2:	74 44                	je     80104d38 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104cf4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104cf7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d01:	01 c2                	add    %eax,%edx
80104d03:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d06:	8b 40 04             	mov    0x4(%eax),%eax
80104d09:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104d0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d0e:	8b 00                	mov    (%eax),%eax
80104d10:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104d13:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d17:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d1b:	7e c2                	jle    80104cdf <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104d1d:	eb 19                	jmp    80104d38 <getcallerpcs+0x71>
    pcs[i] = 0;
80104d1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104d22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104d29:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d2c:	01 d0                	add    %edx,%eax
80104d2e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104d34:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104d38:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104d3c:	7e e1                	jle    80104d1f <getcallerpcs+0x58>
}
80104d3e:	90                   	nop
80104d3f:	90                   	nop
80104d40:	c9                   	leave
80104d41:	c3                   	ret

80104d42 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104d42:	55                   	push   %ebp
80104d43:	89 e5                	mov    %esp,%ebp
80104d45:	53                   	push   %ebx
80104d46:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104d49:	8b 45 08             	mov    0x8(%ebp),%eax
80104d4c:	8b 00                	mov    (%eax),%eax
80104d4e:	85 c0                	test   %eax,%eax
80104d50:	74 16                	je     80104d68 <holding+0x26>
80104d52:	8b 45 08             	mov    0x8(%ebp),%eax
80104d55:	8b 58 08             	mov    0x8(%eax),%ebx
80104d58:	e8 3d f1 ff ff       	call   80103e9a <mycpu>
80104d5d:	39 c3                	cmp    %eax,%ebx
80104d5f:	75 07                	jne    80104d68 <holding+0x26>
80104d61:	b8 01 00 00 00       	mov    $0x1,%eax
80104d66:	eb 05                	jmp    80104d6d <holding+0x2b>
80104d68:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d70:	c9                   	leave
80104d71:	c3                   	ret

80104d72 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104d72:	55                   	push   %ebp
80104d73:	89 e5                	mov    %esp,%ebp
80104d75:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104d78:	e8 30 fe ff ff       	call   80104bad <readeflags>
80104d7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104d80:	e8 38 fe ff ff       	call   80104bbd <cli>
  if(mycpu()->ncli == 0)
80104d85:	e8 10 f1 ff ff       	call   80103e9a <mycpu>
80104d8a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104d90:	85 c0                	test   %eax,%eax
80104d92:	75 14                	jne    80104da8 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104d94:	e8 01 f1 ff ff       	call   80103e9a <mycpu>
80104d99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d9c:	81 e2 00 02 00 00    	and    $0x200,%edx
80104da2:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80104da8:	e8 ed f0 ff ff       	call   80103e9a <mycpu>
80104dad:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104db3:	83 c2 01             	add    $0x1,%edx
80104db6:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80104dbc:	90                   	nop
80104dbd:	c9                   	leave
80104dbe:	c3                   	ret

80104dbf <popcli>:

void
popcli(void)
{
80104dbf:	55                   	push   %ebp
80104dc0:	89 e5                	mov    %esp,%ebp
80104dc2:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80104dc5:	e8 e3 fd ff ff       	call   80104bad <readeflags>
80104dca:	25 00 02 00 00       	and    $0x200,%eax
80104dcf:	85 c0                	test   %eax,%eax
80104dd1:	74 0d                	je     80104de0 <popcli+0x21>
    panic("popcli - interruptible");
80104dd3:	83 ec 0c             	sub    $0xc,%esp
80104dd6:	68 68 a8 10 80       	push   $0x8010a868
80104ddb:	e8 c9 b7 ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
80104de0:	e8 b5 f0 ff ff       	call   80103e9a <mycpu>
80104de5:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104deb:	83 ea 01             	sub    $0x1,%edx
80104dee:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104df4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104dfa:	85 c0                	test   %eax,%eax
80104dfc:	79 0d                	jns    80104e0b <popcli+0x4c>
    panic("popcli");
80104dfe:	83 ec 0c             	sub    $0xc,%esp
80104e01:	68 7f a8 10 80       	push   $0x8010a87f
80104e06:	e8 9e b7 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104e0b:	e8 8a f0 ff ff       	call   80103e9a <mycpu>
80104e10:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104e16:	85 c0                	test   %eax,%eax
80104e18:	75 14                	jne    80104e2e <popcli+0x6f>
80104e1a:	e8 7b f0 ff ff       	call   80103e9a <mycpu>
80104e1f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e25:	85 c0                	test   %eax,%eax
80104e27:	74 05                	je     80104e2e <popcli+0x6f>
    sti();
80104e29:	e8 96 fd ff ff       	call   80104bc4 <sti>
}
80104e2e:	90                   	nop
80104e2f:	c9                   	leave
80104e30:	c3                   	ret

80104e31 <stosb>:
{
80104e31:	55                   	push   %ebp
80104e32:	89 e5                	mov    %esp,%ebp
80104e34:	57                   	push   %edi
80104e35:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e39:	8b 55 10             	mov    0x10(%ebp),%edx
80104e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e3f:	89 cb                	mov    %ecx,%ebx
80104e41:	89 df                	mov    %ebx,%edi
80104e43:	89 d1                	mov    %edx,%ecx
80104e45:	fc                   	cld
80104e46:	f3 aa                	rep stos %al,%es:(%edi)
80104e48:	89 ca                	mov    %ecx,%edx
80104e4a:	89 fb                	mov    %edi,%ebx
80104e4c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e4f:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e52:	90                   	nop
80104e53:	5b                   	pop    %ebx
80104e54:	5f                   	pop    %edi
80104e55:	5d                   	pop    %ebp
80104e56:	c3                   	ret

80104e57 <stosl>:
{
80104e57:	55                   	push   %ebp
80104e58:	89 e5                	mov    %esp,%ebp
80104e5a:	57                   	push   %edi
80104e5b:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104e5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104e5f:	8b 55 10             	mov    0x10(%ebp),%edx
80104e62:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e65:	89 cb                	mov    %ecx,%ebx
80104e67:	89 df                	mov    %ebx,%edi
80104e69:	89 d1                	mov    %edx,%ecx
80104e6b:	fc                   	cld
80104e6c:	f3 ab                	rep stos %eax,%es:(%edi)
80104e6e:	89 ca                	mov    %ecx,%edx
80104e70:	89 fb                	mov    %edi,%ebx
80104e72:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104e75:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104e78:	90                   	nop
80104e79:	5b                   	pop    %ebx
80104e7a:	5f                   	pop    %edi
80104e7b:	5d                   	pop    %ebp
80104e7c:	c3                   	ret

80104e7d <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104e7d:	55                   	push   %ebp
80104e7e:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104e80:	8b 45 08             	mov    0x8(%ebp),%eax
80104e83:	83 e0 03             	and    $0x3,%eax
80104e86:	85 c0                	test   %eax,%eax
80104e88:	75 43                	jne    80104ecd <memset+0x50>
80104e8a:	8b 45 10             	mov    0x10(%ebp),%eax
80104e8d:	83 e0 03             	and    $0x3,%eax
80104e90:	85 c0                	test   %eax,%eax
80104e92:	75 39                	jne    80104ecd <memset+0x50>
    c &= 0xFF;
80104e94:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104e9b:	8b 45 10             	mov    0x10(%ebp),%eax
80104e9e:	c1 e8 02             	shr    $0x2,%eax
80104ea1:	89 c1                	mov    %eax,%ecx
80104ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ea6:	c1 e0 18             	shl    $0x18,%eax
80104ea9:	89 c2                	mov    %eax,%edx
80104eab:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eae:	c1 e0 10             	shl    $0x10,%eax
80104eb1:	09 c2                	or     %eax,%edx
80104eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eb6:	c1 e0 08             	shl    $0x8,%eax
80104eb9:	09 d0                	or     %edx,%eax
80104ebb:	0b 45 0c             	or     0xc(%ebp),%eax
80104ebe:	51                   	push   %ecx
80104ebf:	50                   	push   %eax
80104ec0:	ff 75 08             	push   0x8(%ebp)
80104ec3:	e8 8f ff ff ff       	call   80104e57 <stosl>
80104ec8:	83 c4 0c             	add    $0xc,%esp
80104ecb:	eb 12                	jmp    80104edf <memset+0x62>
  } else
    stosb(dst, c, n);
80104ecd:	8b 45 10             	mov    0x10(%ebp),%eax
80104ed0:	50                   	push   %eax
80104ed1:	ff 75 0c             	push   0xc(%ebp)
80104ed4:	ff 75 08             	push   0x8(%ebp)
80104ed7:	e8 55 ff ff ff       	call   80104e31 <stosb>
80104edc:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104edf:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ee2:	c9                   	leave
80104ee3:	c3                   	ret

80104ee4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104ee4:	55                   	push   %ebp
80104ee5:	89 e5                	mov    %esp,%ebp
80104ee7:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104eea:	8b 45 08             	mov    0x8(%ebp),%eax
80104eed:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ef3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104ef6:	eb 2e                	jmp    80104f26 <memcmp+0x42>
    if(*s1 != *s2)
80104ef8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104efb:	0f b6 10             	movzbl (%eax),%edx
80104efe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f01:	0f b6 00             	movzbl (%eax),%eax
80104f04:	38 c2                	cmp    %al,%dl
80104f06:	74 16                	je     80104f1e <memcmp+0x3a>
      return *s1 - *s2;
80104f08:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f0b:	0f b6 00             	movzbl (%eax),%eax
80104f0e:	0f b6 d0             	movzbl %al,%edx
80104f11:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f14:	0f b6 00             	movzbl (%eax),%eax
80104f17:	0f b6 c0             	movzbl %al,%eax
80104f1a:	29 c2                	sub    %eax,%edx
80104f1c:	eb 1a                	jmp    80104f38 <memcmp+0x54>
    s1++, s2++;
80104f1e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f22:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104f26:	8b 45 10             	mov    0x10(%ebp),%eax
80104f29:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f2c:	89 55 10             	mov    %edx,0x10(%ebp)
80104f2f:	85 c0                	test   %eax,%eax
80104f31:	75 c5                	jne    80104ef8 <memcmp+0x14>
  }

  return 0;
80104f33:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104f38:	89 d0                	mov    %edx,%eax
80104f3a:	c9                   	leave
80104f3b:	c3                   	ret

80104f3c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104f3c:	55                   	push   %ebp
80104f3d:	89 e5                	mov    %esp,%ebp
80104f3f:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104f42:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f45:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104f48:	8b 45 08             	mov    0x8(%ebp),%eax
80104f4b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104f4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f51:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104f54:	73 54                	jae    80104faa <memmove+0x6e>
80104f56:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f59:	8b 45 10             	mov    0x10(%ebp),%eax
80104f5c:	01 d0                	add    %edx,%eax
80104f5e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104f61:	73 47                	jae    80104faa <memmove+0x6e>
    s += n;
80104f63:	8b 45 10             	mov    0x10(%ebp),%eax
80104f66:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104f69:	8b 45 10             	mov    0x10(%ebp),%eax
80104f6c:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104f6f:	eb 13                	jmp    80104f84 <memmove+0x48>
      *--d = *--s;
80104f71:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104f75:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104f79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f7c:	0f b6 10             	movzbl (%eax),%edx
80104f7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f82:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104f84:	8b 45 10             	mov    0x10(%ebp),%eax
80104f87:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f8a:	89 55 10             	mov    %edx,0x10(%ebp)
80104f8d:	85 c0                	test   %eax,%eax
80104f8f:	75 e0                	jne    80104f71 <memmove+0x35>
  if(s < d && s + n > d){
80104f91:	eb 24                	jmp    80104fb7 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104f93:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f96:	8d 42 01             	lea    0x1(%edx),%eax
80104f99:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104f9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f9f:	8d 48 01             	lea    0x1(%eax),%ecx
80104fa2:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104fa5:	0f b6 12             	movzbl (%edx),%edx
80104fa8:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104faa:	8b 45 10             	mov    0x10(%ebp),%eax
80104fad:	8d 50 ff             	lea    -0x1(%eax),%edx
80104fb0:	89 55 10             	mov    %edx,0x10(%ebp)
80104fb3:	85 c0                	test   %eax,%eax
80104fb5:	75 dc                	jne    80104f93 <memmove+0x57>

  return dst;
80104fb7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104fba:	c9                   	leave
80104fbb:	c3                   	ret

80104fbc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104fbc:	55                   	push   %ebp
80104fbd:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104fbf:	ff 75 10             	push   0x10(%ebp)
80104fc2:	ff 75 0c             	push   0xc(%ebp)
80104fc5:	ff 75 08             	push   0x8(%ebp)
80104fc8:	e8 6f ff ff ff       	call   80104f3c <memmove>
80104fcd:	83 c4 0c             	add    $0xc,%esp
}
80104fd0:	c9                   	leave
80104fd1:	c3                   	ret

80104fd2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104fd2:	55                   	push   %ebp
80104fd3:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104fd5:	eb 0c                	jmp    80104fe3 <strncmp+0x11>
    n--, p++, q++;
80104fd7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104fdb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104fdf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104fe3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fe7:	74 1a                	je     80105003 <strncmp+0x31>
80104fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fec:	0f b6 00             	movzbl (%eax),%eax
80104fef:	84 c0                	test   %al,%al
80104ff1:	74 10                	je     80105003 <strncmp+0x31>
80104ff3:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff6:	0f b6 10             	movzbl (%eax),%edx
80104ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ffc:	0f b6 00             	movzbl (%eax),%eax
80104fff:	38 c2                	cmp    %al,%dl
80105001:	74 d4                	je     80104fd7 <strncmp+0x5>
  if(n == 0)
80105003:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105007:	75 07                	jne    80105010 <strncmp+0x3e>
    return 0;
80105009:	ba 00 00 00 00       	mov    $0x0,%edx
8010500e:	eb 14                	jmp    80105024 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80105010:	8b 45 08             	mov    0x8(%ebp),%eax
80105013:	0f b6 00             	movzbl (%eax),%eax
80105016:	0f b6 d0             	movzbl %al,%edx
80105019:	8b 45 0c             	mov    0xc(%ebp),%eax
8010501c:	0f b6 00             	movzbl (%eax),%eax
8010501f:	0f b6 c0             	movzbl %al,%eax
80105022:	29 c2                	sub    %eax,%edx
}
80105024:	89 d0                	mov    %edx,%eax
80105026:	5d                   	pop    %ebp
80105027:	c3                   	ret

80105028 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105028:	55                   	push   %ebp
80105029:	89 e5                	mov    %esp,%ebp
8010502b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010502e:	8b 45 08             	mov    0x8(%ebp),%eax
80105031:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105034:	90                   	nop
80105035:	8b 45 10             	mov    0x10(%ebp),%eax
80105038:	8d 50 ff             	lea    -0x1(%eax),%edx
8010503b:	89 55 10             	mov    %edx,0x10(%ebp)
8010503e:	85 c0                	test   %eax,%eax
80105040:	7e 2c                	jle    8010506e <strncpy+0x46>
80105042:	8b 55 0c             	mov    0xc(%ebp),%edx
80105045:	8d 42 01             	lea    0x1(%edx),%eax
80105048:	89 45 0c             	mov    %eax,0xc(%ebp)
8010504b:	8b 45 08             	mov    0x8(%ebp),%eax
8010504e:	8d 48 01             	lea    0x1(%eax),%ecx
80105051:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105054:	0f b6 12             	movzbl (%edx),%edx
80105057:	88 10                	mov    %dl,(%eax)
80105059:	0f b6 00             	movzbl (%eax),%eax
8010505c:	84 c0                	test   %al,%al
8010505e:	75 d5                	jne    80105035 <strncpy+0xd>
    ;
  while(n-- > 0)
80105060:	eb 0c                	jmp    8010506e <strncpy+0x46>
    *s++ = 0;
80105062:	8b 45 08             	mov    0x8(%ebp),%eax
80105065:	8d 50 01             	lea    0x1(%eax),%edx
80105068:	89 55 08             	mov    %edx,0x8(%ebp)
8010506b:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010506e:	8b 45 10             	mov    0x10(%ebp),%eax
80105071:	8d 50 ff             	lea    -0x1(%eax),%edx
80105074:	89 55 10             	mov    %edx,0x10(%ebp)
80105077:	85 c0                	test   %eax,%eax
80105079:	7f e7                	jg     80105062 <strncpy+0x3a>
  return os;
8010507b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010507e:	c9                   	leave
8010507f:	c3                   	ret

80105080 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105080:	55                   	push   %ebp
80105081:	89 e5                	mov    %esp,%ebp
80105083:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105086:	8b 45 08             	mov    0x8(%ebp),%eax
80105089:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010508c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105090:	7f 05                	jg     80105097 <safestrcpy+0x17>
    return os;
80105092:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105095:	eb 32                	jmp    801050c9 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105097:	90                   	nop
80105098:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010509c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801050a0:	7e 1e                	jle    801050c0 <safestrcpy+0x40>
801050a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801050a5:	8d 42 01             	lea    0x1(%edx),%eax
801050a8:	89 45 0c             	mov    %eax,0xc(%ebp)
801050ab:	8b 45 08             	mov    0x8(%ebp),%eax
801050ae:	8d 48 01             	lea    0x1(%eax),%ecx
801050b1:	89 4d 08             	mov    %ecx,0x8(%ebp)
801050b4:	0f b6 12             	movzbl (%edx),%edx
801050b7:	88 10                	mov    %dl,(%eax)
801050b9:	0f b6 00             	movzbl (%eax),%eax
801050bc:	84 c0                	test   %al,%al
801050be:	75 d8                	jne    80105098 <safestrcpy+0x18>
    ;
  *s = 0;
801050c0:	8b 45 08             	mov    0x8(%ebp),%eax
801050c3:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801050c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050c9:	c9                   	leave
801050ca:	c3                   	ret

801050cb <strlen>:

int
strlen(const char *s)
{
801050cb:	55                   	push   %ebp
801050cc:	89 e5                	mov    %esp,%ebp
801050ce:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801050d1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801050d8:	eb 04                	jmp    801050de <strlen+0x13>
801050da:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801050de:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050e1:	8b 45 08             	mov    0x8(%ebp),%eax
801050e4:	01 d0                	add    %edx,%eax
801050e6:	0f b6 00             	movzbl (%eax),%eax
801050e9:	84 c0                	test   %al,%al
801050eb:	75 ed                	jne    801050da <strlen+0xf>
    ;
  return n;
801050ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801050f0:	c9                   	leave
801050f1:	c3                   	ret

801050f2 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801050f2:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801050f6:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801050fa:	55                   	push   %ebp
  pushl %ebx
801050fb:	53                   	push   %ebx
  pushl %esi
801050fc:	56                   	push   %esi
  pushl %edi
801050fd:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801050fe:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105100:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105102:	5f                   	pop    %edi
  popl %esi
80105103:	5e                   	pop    %esi
  popl %ebx
80105104:	5b                   	pop    %ebx
  popl %ebp
80105105:	5d                   	pop    %ebp
  ret
80105106:	c3                   	ret

80105107 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105107:	55                   	push   %ebp
80105108:	89 e5                	mov    %esp,%ebp
8010510a:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010510d:	e8 00 ee ff ff       	call   80103f12 <myproc>
80105112:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105118:	8b 00                	mov    (%eax),%eax
8010511a:	39 45 08             	cmp    %eax,0x8(%ebp)
8010511d:	73 0f                	jae    8010512e <fetchint+0x27>
8010511f:	8b 45 08             	mov    0x8(%ebp),%eax
80105122:	8d 50 04             	lea    0x4(%eax),%edx
80105125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105128:	8b 00                	mov    (%eax),%eax
8010512a:	39 d0                	cmp    %edx,%eax
8010512c:	73 07                	jae    80105135 <fetchint+0x2e>
    return -1;
8010512e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105133:	eb 0f                	jmp    80105144 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105135:	8b 45 08             	mov    0x8(%ebp),%eax
80105138:	8b 10                	mov    (%eax),%edx
8010513a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513d:	89 10                	mov    %edx,(%eax)
  return 0;
8010513f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105144:	c9                   	leave
80105145:	c3                   	ret

80105146 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105146:	55                   	push   %ebp
80105147:	89 e5                	mov    %esp,%ebp
80105149:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
8010514c:	e8 c1 ed ff ff       	call   80103f12 <myproc>
80105151:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105157:	8b 00                	mov    (%eax),%eax
80105159:	39 45 08             	cmp    %eax,0x8(%ebp)
8010515c:	72 07                	jb     80105165 <fetchstr+0x1f>
    return -1;
8010515e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105163:	eb 41                	jmp    801051a6 <fetchstr+0x60>
  *pp = (char*)addr;
80105165:	8b 55 08             	mov    0x8(%ebp),%edx
80105168:	8b 45 0c             	mov    0xc(%ebp),%eax
8010516b:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
8010516d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105170:	8b 00                	mov    (%eax),%eax
80105172:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105175:	8b 45 0c             	mov    0xc(%ebp),%eax
80105178:	8b 00                	mov    (%eax),%eax
8010517a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010517d:	eb 1a                	jmp    80105199 <fetchstr+0x53>
    if(*s == 0)
8010517f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105182:	0f b6 00             	movzbl (%eax),%eax
80105185:	84 c0                	test   %al,%al
80105187:	75 0c                	jne    80105195 <fetchstr+0x4f>
      return s - *pp;
80105189:	8b 45 0c             	mov    0xc(%ebp),%eax
8010518c:	8b 10                	mov    (%eax),%edx
8010518e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105191:	29 d0                	sub    %edx,%eax
80105193:	eb 11                	jmp    801051a6 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80105195:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010519f:	72 de                	jb     8010517f <fetchstr+0x39>
  }
  return -1;
801051a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801051a6:	c9                   	leave
801051a7:	c3                   	ret

801051a8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801051a8:	55                   	push   %ebp
801051a9:	89 e5                	mov    %esp,%ebp
801051ab:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801051ae:	e8 5f ed ff ff       	call   80103f12 <myproc>
801051b3:	8b 40 18             	mov    0x18(%eax),%eax
801051b6:	8b 40 44             	mov    0x44(%eax),%eax
801051b9:	8b 55 08             	mov    0x8(%ebp),%edx
801051bc:	c1 e2 02             	shl    $0x2,%edx
801051bf:	01 d0                	add    %edx,%eax
801051c1:	83 c0 04             	add    $0x4,%eax
801051c4:	83 ec 08             	sub    $0x8,%esp
801051c7:	ff 75 0c             	push   0xc(%ebp)
801051ca:	50                   	push   %eax
801051cb:	e8 37 ff ff ff       	call   80105107 <fetchint>
801051d0:	83 c4 10             	add    $0x10,%esp
}
801051d3:	c9                   	leave
801051d4:	c3                   	ret

801051d5 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801051d5:	55                   	push   %ebp
801051d6:	89 e5                	mov    %esp,%ebp
801051d8:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
801051db:	e8 32 ed ff ff       	call   80103f12 <myproc>
801051e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
801051e3:	83 ec 08             	sub    $0x8,%esp
801051e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051e9:	50                   	push   %eax
801051ea:	ff 75 08             	push   0x8(%ebp)
801051ed:	e8 b6 ff ff ff       	call   801051a8 <argint>
801051f2:	83 c4 10             	add    $0x10,%esp
801051f5:	85 c0                	test   %eax,%eax
801051f7:	79 07                	jns    80105200 <argptr+0x2b>
    return -1;
801051f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051fe:	eb 3b                	jmp    8010523b <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105200:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105204:	78 1f                	js     80105225 <argptr+0x50>
80105206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105209:	8b 00                	mov    (%eax),%eax
8010520b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010520e:	39 c2                	cmp    %eax,%edx
80105210:	73 13                	jae    80105225 <argptr+0x50>
80105212:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105215:	89 c2                	mov    %eax,%edx
80105217:	8b 45 10             	mov    0x10(%ebp),%eax
8010521a:	01 c2                	add    %eax,%edx
8010521c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521f:	8b 00                	mov    (%eax),%eax
80105221:	39 d0                	cmp    %edx,%eax
80105223:	73 07                	jae    8010522c <argptr+0x57>
    return -1;
80105225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010522a:	eb 0f                	jmp    8010523b <argptr+0x66>
  *pp = (char*)i;
8010522c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010522f:	89 c2                	mov    %eax,%edx
80105231:	8b 45 0c             	mov    0xc(%ebp),%eax
80105234:	89 10                	mov    %edx,(%eax)
  return 0;
80105236:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010523b:	c9                   	leave
8010523c:	c3                   	ret

8010523d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010523d:	55                   	push   %ebp
8010523e:	89 e5                	mov    %esp,%ebp
80105240:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105243:	83 ec 08             	sub    $0x8,%esp
80105246:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105249:	50                   	push   %eax
8010524a:	ff 75 08             	push   0x8(%ebp)
8010524d:	e8 56 ff ff ff       	call   801051a8 <argint>
80105252:	83 c4 10             	add    $0x10,%esp
80105255:	85 c0                	test   %eax,%eax
80105257:	79 07                	jns    80105260 <argstr+0x23>
    return -1;
80105259:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010525e:	eb 12                	jmp    80105272 <argstr+0x35>
  return fetchstr(addr, pp);
80105260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105263:	83 ec 08             	sub    $0x8,%esp
80105266:	ff 75 0c             	push   0xc(%ebp)
80105269:	50                   	push   %eax
8010526a:	e8 d7 fe ff ff       	call   80105146 <fetchstr>
8010526f:	83 c4 10             	add    $0x10,%esp
}
80105272:	c9                   	leave
80105273:	c3                   	ret

80105274 <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80105274:	55                   	push   %ebp
80105275:	89 e5                	mov    %esp,%ebp
80105277:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
8010527a:	e8 93 ec ff ff       	call   80103f12 <myproc>
8010527f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105285:	8b 40 18             	mov    0x18(%eax),%eax
80105288:	8b 40 1c             	mov    0x1c(%eax),%eax
8010528b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010528e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105292:	7e 2f                	jle    801052c3 <syscall+0x4f>
80105294:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105297:	83 f8 16             	cmp    $0x16,%eax
8010529a:	77 27                	ja     801052c3 <syscall+0x4f>
8010529c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010529f:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801052a6:	85 c0                	test   %eax,%eax
801052a8:	74 19                	je     801052c3 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
801052aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ad:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
801052b4:	ff d0                	call   *%eax
801052b6:	89 c2                	mov    %eax,%edx
801052b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052bb:	8b 40 18             	mov    0x18(%eax),%eax
801052be:	89 50 1c             	mov    %edx,0x1c(%eax)
801052c1:	eb 2c                	jmp    801052ef <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
801052c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c6:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
801052c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052cc:	8b 40 10             	mov    0x10(%eax),%eax
801052cf:	ff 75 f0             	push   -0x10(%ebp)
801052d2:	52                   	push   %edx
801052d3:	50                   	push   %eax
801052d4:	68 86 a8 10 80       	push   $0x8010a886
801052d9:	e8 16 b1 ff ff       	call   801003f4 <cprintf>
801052de:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
801052e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e4:	8b 40 18             	mov    0x18(%eax),%eax
801052e7:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801052ee:	90                   	nop
801052ef:	90                   	nop
801052f0:	c9                   	leave
801052f1:	c3                   	ret

801052f2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801052f2:	55                   	push   %ebp
801052f3:	89 e5                	mov    %esp,%ebp
801052f5:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801052f8:	83 ec 08             	sub    $0x8,%esp
801052fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052fe:	50                   	push   %eax
801052ff:	ff 75 08             	push   0x8(%ebp)
80105302:	e8 a1 fe ff ff       	call   801051a8 <argint>
80105307:	83 c4 10             	add    $0x10,%esp
8010530a:	85 c0                	test   %eax,%eax
8010530c:	79 07                	jns    80105315 <argfd+0x23>
    return -1;
8010530e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105313:	eb 4f                	jmp    80105364 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105318:	85 c0                	test   %eax,%eax
8010531a:	78 20                	js     8010533c <argfd+0x4a>
8010531c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010531f:	83 f8 0f             	cmp    $0xf,%eax
80105322:	7f 18                	jg     8010533c <argfd+0x4a>
80105324:	e8 e9 eb ff ff       	call   80103f12 <myproc>
80105329:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010532c:	83 c2 08             	add    $0x8,%edx
8010532f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105333:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105336:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010533a:	75 07                	jne    80105343 <argfd+0x51>
    return -1;
8010533c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105341:	eb 21                	jmp    80105364 <argfd+0x72>
  if(pfd)
80105343:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105347:	74 08                	je     80105351 <argfd+0x5f>
    *pfd = fd;
80105349:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010534c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010534f:	89 10                	mov    %edx,(%eax)
  if(pf)
80105351:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105355:	74 08                	je     8010535f <argfd+0x6d>
    *pf = f;
80105357:	8b 45 10             	mov    0x10(%ebp),%eax
8010535a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010535d:	89 10                	mov    %edx,(%eax)
  return 0;
8010535f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105364:	c9                   	leave
80105365:	c3                   	ret

80105366 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105366:	55                   	push   %ebp
80105367:	89 e5                	mov    %esp,%ebp
80105369:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010536c:	e8 a1 eb ff ff       	call   80103f12 <myproc>
80105371:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105374:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010537b:	eb 2a                	jmp    801053a7 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
8010537d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105380:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105383:	83 c2 08             	add    $0x8,%edx
80105386:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010538a:	85 c0                	test   %eax,%eax
8010538c:	75 15                	jne    801053a3 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010538e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105391:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105394:	8d 4a 08             	lea    0x8(%edx),%ecx
80105397:	8b 55 08             	mov    0x8(%ebp),%edx
8010539a:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010539e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a1:	eb 0f                	jmp    801053b2 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
801053a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801053a7:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801053ab:	7e d0                	jle    8010537d <fdalloc+0x17>
    }
  }
  return -1;
801053ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053b2:	c9                   	leave
801053b3:	c3                   	ret

801053b4 <sys_dup>:

int
sys_dup(void)
{
801053b4:	55                   	push   %ebp
801053b5:	89 e5                	mov    %esp,%ebp
801053b7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801053ba:	83 ec 04             	sub    $0x4,%esp
801053bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053c0:	50                   	push   %eax
801053c1:	6a 00                	push   $0x0
801053c3:	6a 00                	push   $0x0
801053c5:	e8 28 ff ff ff       	call   801052f2 <argfd>
801053ca:	83 c4 10             	add    $0x10,%esp
801053cd:	85 c0                	test   %eax,%eax
801053cf:	79 07                	jns    801053d8 <sys_dup+0x24>
    return -1;
801053d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d6:	eb 31                	jmp    80105409 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801053d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053db:	83 ec 0c             	sub    $0xc,%esp
801053de:	50                   	push   %eax
801053df:	e8 82 ff ff ff       	call   80105366 <fdalloc>
801053e4:	83 c4 10             	add    $0x10,%esp
801053e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053ee:	79 07                	jns    801053f7 <sys_dup+0x43>
    return -1;
801053f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053f5:	eb 12                	jmp    80105409 <sys_dup+0x55>
  filedup(f);
801053f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053fa:	83 ec 0c             	sub    $0xc,%esp
801053fd:	50                   	push   %eax
801053fe:	e8 51 bc ff ff       	call   80101054 <filedup>
80105403:	83 c4 10             	add    $0x10,%esp
  return fd;
80105406:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105409:	c9                   	leave
8010540a:	c3                   	ret

8010540b <sys_read>:

int
sys_read(void)
{
8010540b:	55                   	push   %ebp
8010540c:	89 e5                	mov    %esp,%ebp
8010540e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105411:	83 ec 04             	sub    $0x4,%esp
80105414:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105417:	50                   	push   %eax
80105418:	6a 00                	push   $0x0
8010541a:	6a 00                	push   $0x0
8010541c:	e8 d1 fe ff ff       	call   801052f2 <argfd>
80105421:	83 c4 10             	add    $0x10,%esp
80105424:	85 c0                	test   %eax,%eax
80105426:	78 2e                	js     80105456 <sys_read+0x4b>
80105428:	83 ec 08             	sub    $0x8,%esp
8010542b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010542e:	50                   	push   %eax
8010542f:	6a 02                	push   $0x2
80105431:	e8 72 fd ff ff       	call   801051a8 <argint>
80105436:	83 c4 10             	add    $0x10,%esp
80105439:	85 c0                	test   %eax,%eax
8010543b:	78 19                	js     80105456 <sys_read+0x4b>
8010543d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105440:	83 ec 04             	sub    $0x4,%esp
80105443:	50                   	push   %eax
80105444:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105447:	50                   	push   %eax
80105448:	6a 01                	push   $0x1
8010544a:	e8 86 fd ff ff       	call   801051d5 <argptr>
8010544f:	83 c4 10             	add    $0x10,%esp
80105452:	85 c0                	test   %eax,%eax
80105454:	79 07                	jns    8010545d <sys_read+0x52>
    return -1;
80105456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545b:	eb 17                	jmp    80105474 <sys_read+0x69>
  return fileread(f, p, n);
8010545d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105460:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105463:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105466:	83 ec 04             	sub    $0x4,%esp
80105469:	51                   	push   %ecx
8010546a:	52                   	push   %edx
8010546b:	50                   	push   %eax
8010546c:	e8 73 bd ff ff       	call   801011e4 <fileread>
80105471:	83 c4 10             	add    $0x10,%esp
}
80105474:	c9                   	leave
80105475:	c3                   	ret

80105476 <sys_write>:

int
sys_write(void)
{
80105476:	55                   	push   %ebp
80105477:	89 e5                	mov    %esp,%ebp
80105479:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010547c:	83 ec 04             	sub    $0x4,%esp
8010547f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105482:	50                   	push   %eax
80105483:	6a 00                	push   $0x0
80105485:	6a 00                	push   $0x0
80105487:	e8 66 fe ff ff       	call   801052f2 <argfd>
8010548c:	83 c4 10             	add    $0x10,%esp
8010548f:	85 c0                	test   %eax,%eax
80105491:	78 2e                	js     801054c1 <sys_write+0x4b>
80105493:	83 ec 08             	sub    $0x8,%esp
80105496:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105499:	50                   	push   %eax
8010549a:	6a 02                	push   $0x2
8010549c:	e8 07 fd ff ff       	call   801051a8 <argint>
801054a1:	83 c4 10             	add    $0x10,%esp
801054a4:	85 c0                	test   %eax,%eax
801054a6:	78 19                	js     801054c1 <sys_write+0x4b>
801054a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ab:	83 ec 04             	sub    $0x4,%esp
801054ae:	50                   	push   %eax
801054af:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054b2:	50                   	push   %eax
801054b3:	6a 01                	push   $0x1
801054b5:	e8 1b fd ff ff       	call   801051d5 <argptr>
801054ba:	83 c4 10             	add    $0x10,%esp
801054bd:	85 c0                	test   %eax,%eax
801054bf:	79 07                	jns    801054c8 <sys_write+0x52>
    return -1;
801054c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c6:	eb 17                	jmp    801054df <sys_write+0x69>
  return filewrite(f, p, n);
801054c8:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801054cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801054ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d1:	83 ec 04             	sub    $0x4,%esp
801054d4:	51                   	push   %ecx
801054d5:	52                   	push   %edx
801054d6:	50                   	push   %eax
801054d7:	e8 c0 bd ff ff       	call   8010129c <filewrite>
801054dc:	83 c4 10             	add    $0x10,%esp
}
801054df:	c9                   	leave
801054e0:	c3                   	ret

801054e1 <sys_close>:

int
sys_close(void)
{
801054e1:	55                   	push   %ebp
801054e2:	89 e5                	mov    %esp,%ebp
801054e4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801054e7:	83 ec 04             	sub    $0x4,%esp
801054ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054ed:	50                   	push   %eax
801054ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054f1:	50                   	push   %eax
801054f2:	6a 00                	push   $0x0
801054f4:	e8 f9 fd ff ff       	call   801052f2 <argfd>
801054f9:	83 c4 10             	add    $0x10,%esp
801054fc:	85 c0                	test   %eax,%eax
801054fe:	79 07                	jns    80105507 <sys_close+0x26>
    return -1;
80105500:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105505:	eb 27                	jmp    8010552e <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105507:	e8 06 ea ff ff       	call   80103f12 <myproc>
8010550c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010550f:	83 c2 08             	add    $0x8,%edx
80105512:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105519:	00 
  fileclose(f);
8010551a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010551d:	83 ec 0c             	sub    $0xc,%esp
80105520:	50                   	push   %eax
80105521:	e8 7f bb ff ff       	call   801010a5 <fileclose>
80105526:	83 c4 10             	add    $0x10,%esp
  return 0;
80105529:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010552e:	c9                   	leave
8010552f:	c3                   	ret

80105530 <sys_fstat>:

int
sys_fstat(void)
{
80105530:	55                   	push   %ebp
80105531:	89 e5                	mov    %esp,%ebp
80105533:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105536:	83 ec 04             	sub    $0x4,%esp
80105539:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010553c:	50                   	push   %eax
8010553d:	6a 00                	push   $0x0
8010553f:	6a 00                	push   $0x0
80105541:	e8 ac fd ff ff       	call   801052f2 <argfd>
80105546:	83 c4 10             	add    $0x10,%esp
80105549:	85 c0                	test   %eax,%eax
8010554b:	78 17                	js     80105564 <sys_fstat+0x34>
8010554d:	83 ec 04             	sub    $0x4,%esp
80105550:	6a 14                	push   $0x14
80105552:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105555:	50                   	push   %eax
80105556:	6a 01                	push   $0x1
80105558:	e8 78 fc ff ff       	call   801051d5 <argptr>
8010555d:	83 c4 10             	add    $0x10,%esp
80105560:	85 c0                	test   %eax,%eax
80105562:	79 07                	jns    8010556b <sys_fstat+0x3b>
    return -1;
80105564:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105569:	eb 13                	jmp    8010557e <sys_fstat+0x4e>
  return filestat(f, st);
8010556b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010556e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105571:	83 ec 08             	sub    $0x8,%esp
80105574:	52                   	push   %edx
80105575:	50                   	push   %eax
80105576:	e8 12 bc ff ff       	call   8010118d <filestat>
8010557b:	83 c4 10             	add    $0x10,%esp
}
8010557e:	c9                   	leave
8010557f:	c3                   	ret

80105580 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105580:	55                   	push   %ebp
80105581:	89 e5                	mov    %esp,%ebp
80105583:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105586:	83 ec 08             	sub    $0x8,%esp
80105589:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010558c:	50                   	push   %eax
8010558d:	6a 00                	push   $0x0
8010558f:	e8 a9 fc ff ff       	call   8010523d <argstr>
80105594:	83 c4 10             	add    $0x10,%esp
80105597:	85 c0                	test   %eax,%eax
80105599:	78 15                	js     801055b0 <sys_link+0x30>
8010559b:	83 ec 08             	sub    $0x8,%esp
8010559e:	8d 45 dc             	lea    -0x24(%ebp),%eax
801055a1:	50                   	push   %eax
801055a2:	6a 01                	push   $0x1
801055a4:	e8 94 fc ff ff       	call   8010523d <argstr>
801055a9:	83 c4 10             	add    $0x10,%esp
801055ac:	85 c0                	test   %eax,%eax
801055ae:	79 0a                	jns    801055ba <sys_link+0x3a>
    return -1;
801055b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b5:	e9 68 01 00 00       	jmp    80105722 <sys_link+0x1a2>

  begin_op();
801055ba:	e8 61 df ff ff       	call   80103520 <begin_op>
  if((ip = namei(old)) == 0){
801055bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801055c2:	83 ec 0c             	sub    $0xc,%esp
801055c5:	50                   	push   %eax
801055c6:	e8 5a cf ff ff       	call   80102525 <namei>
801055cb:	83 c4 10             	add    $0x10,%esp
801055ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055d5:	75 0f                	jne    801055e6 <sys_link+0x66>
    end_op();
801055d7:	e8 d0 df ff ff       	call   801035ac <end_op>
    return -1;
801055dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055e1:	e9 3c 01 00 00       	jmp    80105722 <sys_link+0x1a2>
  }

  ilock(ip);
801055e6:	83 ec 0c             	sub    $0xc,%esp
801055e9:	ff 75 f4             	push   -0xc(%ebp)
801055ec:	e8 01 c4 ff ff       	call   801019f2 <ilock>
801055f1:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801055f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055fb:	66 83 f8 01          	cmp    $0x1,%ax
801055ff:	75 1d                	jne    8010561e <sys_link+0x9e>
    iunlockput(ip);
80105601:	83 ec 0c             	sub    $0xc,%esp
80105604:	ff 75 f4             	push   -0xc(%ebp)
80105607:	e8 17 c6 ff ff       	call   80101c23 <iunlockput>
8010560c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010560f:	e8 98 df ff ff       	call   801035ac <end_op>
    return -1;
80105614:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105619:	e9 04 01 00 00       	jmp    80105722 <sys_link+0x1a2>
  }

  ip->nlink++;
8010561e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105621:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105625:	83 c0 01             	add    $0x1,%eax
80105628:	89 c2                	mov    %eax,%edx
8010562a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010562d:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105631:	83 ec 0c             	sub    $0xc,%esp
80105634:	ff 75 f4             	push   -0xc(%ebp)
80105637:	e8 d9 c1 ff ff       	call   80101815 <iupdate>
8010563c:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010563f:	83 ec 0c             	sub    $0xc,%esp
80105642:	ff 75 f4             	push   -0xc(%ebp)
80105645:	e8 bb c4 ff ff       	call   80101b05 <iunlock>
8010564a:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010564d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105650:	83 ec 08             	sub    $0x8,%esp
80105653:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105656:	52                   	push   %edx
80105657:	50                   	push   %eax
80105658:	e8 e4 ce ff ff       	call   80102541 <nameiparent>
8010565d:	83 c4 10             	add    $0x10,%esp
80105660:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105663:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105667:	74 71                	je     801056da <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105669:	83 ec 0c             	sub    $0xc,%esp
8010566c:	ff 75 f0             	push   -0x10(%ebp)
8010566f:	e8 7e c3 ff ff       	call   801019f2 <ilock>
80105674:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105677:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010567a:	8b 10                	mov    (%eax),%edx
8010567c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010567f:	8b 00                	mov    (%eax),%eax
80105681:	39 c2                	cmp    %eax,%edx
80105683:	75 1d                	jne    801056a2 <sys_link+0x122>
80105685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105688:	8b 40 04             	mov    0x4(%eax),%eax
8010568b:	83 ec 04             	sub    $0x4,%esp
8010568e:	50                   	push   %eax
8010568f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105692:	50                   	push   %eax
80105693:	ff 75 f0             	push   -0x10(%ebp)
80105696:	e8 f3 cb ff ff       	call   8010228e <dirlink>
8010569b:	83 c4 10             	add    $0x10,%esp
8010569e:	85 c0                	test   %eax,%eax
801056a0:	79 10                	jns    801056b2 <sys_link+0x132>
    iunlockput(dp);
801056a2:	83 ec 0c             	sub    $0xc,%esp
801056a5:	ff 75 f0             	push   -0x10(%ebp)
801056a8:	e8 76 c5 ff ff       	call   80101c23 <iunlockput>
801056ad:	83 c4 10             	add    $0x10,%esp
    goto bad;
801056b0:	eb 29                	jmp    801056db <sys_link+0x15b>
  }
  iunlockput(dp);
801056b2:	83 ec 0c             	sub    $0xc,%esp
801056b5:	ff 75 f0             	push   -0x10(%ebp)
801056b8:	e8 66 c5 ff ff       	call   80101c23 <iunlockput>
801056bd:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801056c0:	83 ec 0c             	sub    $0xc,%esp
801056c3:	ff 75 f4             	push   -0xc(%ebp)
801056c6:	e8 88 c4 ff ff       	call   80101b53 <iput>
801056cb:	83 c4 10             	add    $0x10,%esp

  end_op();
801056ce:	e8 d9 de ff ff       	call   801035ac <end_op>

  return 0;
801056d3:	b8 00 00 00 00       	mov    $0x0,%eax
801056d8:	eb 48                	jmp    80105722 <sys_link+0x1a2>
    goto bad;
801056da:	90                   	nop

bad:
  ilock(ip);
801056db:	83 ec 0c             	sub    $0xc,%esp
801056de:	ff 75 f4             	push   -0xc(%ebp)
801056e1:	e8 0c c3 ff ff       	call   801019f2 <ilock>
801056e6:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801056e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ec:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801056f0:	83 e8 01             	sub    $0x1,%eax
801056f3:	89 c2                	mov    %eax,%edx
801056f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f8:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801056fc:	83 ec 0c             	sub    $0xc,%esp
801056ff:	ff 75 f4             	push   -0xc(%ebp)
80105702:	e8 0e c1 ff ff       	call   80101815 <iupdate>
80105707:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010570a:	83 ec 0c             	sub    $0xc,%esp
8010570d:	ff 75 f4             	push   -0xc(%ebp)
80105710:	e8 0e c5 ff ff       	call   80101c23 <iunlockput>
80105715:	83 c4 10             	add    $0x10,%esp
  end_op();
80105718:	e8 8f de ff ff       	call   801035ac <end_op>
  return -1;
8010571d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105722:	c9                   	leave
80105723:	c3                   	ret

80105724 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105724:	55                   	push   %ebp
80105725:	89 e5                	mov    %esp,%ebp
80105727:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010572a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105731:	eb 40                	jmp    80105773 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105736:	6a 10                	push   $0x10
80105738:	50                   	push   %eax
80105739:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010573c:	50                   	push   %eax
8010573d:	ff 75 08             	push   0x8(%ebp)
80105740:	e8 99 c7 ff ff       	call   80101ede <readi>
80105745:	83 c4 10             	add    $0x10,%esp
80105748:	83 f8 10             	cmp    $0x10,%eax
8010574b:	74 0d                	je     8010575a <isdirempty+0x36>
      panic("isdirempty: readi");
8010574d:	83 ec 0c             	sub    $0xc,%esp
80105750:	68 a2 a8 10 80       	push   $0x8010a8a2
80105755:	e8 4f ae ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
8010575a:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010575e:	66 85 c0             	test   %ax,%ax
80105761:	74 07                	je     8010576a <isdirempty+0x46>
      return 0;
80105763:	b8 00 00 00 00       	mov    $0x0,%eax
80105768:	eb 1b                	jmp    80105785 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010576a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010576d:	83 c0 10             	add    $0x10,%eax
80105770:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105773:	8b 45 08             	mov    0x8(%ebp),%eax
80105776:	8b 40 58             	mov    0x58(%eax),%eax
80105779:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010577c:	39 c2                	cmp    %eax,%edx
8010577e:	72 b3                	jb     80105733 <isdirempty+0xf>
  }
  return 1;
80105780:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105785:	c9                   	leave
80105786:	c3                   	ret

80105787 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105787:	55                   	push   %ebp
80105788:	89 e5                	mov    %esp,%ebp
8010578a:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010578d:	83 ec 08             	sub    $0x8,%esp
80105790:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105793:	50                   	push   %eax
80105794:	6a 00                	push   $0x0
80105796:	e8 a2 fa ff ff       	call   8010523d <argstr>
8010579b:	83 c4 10             	add    $0x10,%esp
8010579e:	85 c0                	test   %eax,%eax
801057a0:	79 0a                	jns    801057ac <sys_unlink+0x25>
    return -1;
801057a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a7:	e9 bf 01 00 00       	jmp    8010596b <sys_unlink+0x1e4>

  begin_op();
801057ac:	e8 6f dd ff ff       	call   80103520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801057b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801057b4:	83 ec 08             	sub    $0x8,%esp
801057b7:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801057ba:	52                   	push   %edx
801057bb:	50                   	push   %eax
801057bc:	e8 80 cd ff ff       	call   80102541 <nameiparent>
801057c1:	83 c4 10             	add    $0x10,%esp
801057c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057cb:	75 0f                	jne    801057dc <sys_unlink+0x55>
    end_op();
801057cd:	e8 da dd ff ff       	call   801035ac <end_op>
    return -1;
801057d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d7:	e9 8f 01 00 00       	jmp    8010596b <sys_unlink+0x1e4>
  }

  ilock(dp);
801057dc:	83 ec 0c             	sub    $0xc,%esp
801057df:	ff 75 f4             	push   -0xc(%ebp)
801057e2:	e8 0b c2 ff ff       	call   801019f2 <ilock>
801057e7:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801057ea:	83 ec 08             	sub    $0x8,%esp
801057ed:	68 b4 a8 10 80       	push   $0x8010a8b4
801057f2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057f5:	50                   	push   %eax
801057f6:	e8 be c9 ff ff       	call   801021b9 <namecmp>
801057fb:	83 c4 10             	add    $0x10,%esp
801057fe:	85 c0                	test   %eax,%eax
80105800:	0f 84 49 01 00 00    	je     8010594f <sys_unlink+0x1c8>
80105806:	83 ec 08             	sub    $0x8,%esp
80105809:	68 b6 a8 10 80       	push   $0x8010a8b6
8010580e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105811:	50                   	push   %eax
80105812:	e8 a2 c9 ff ff       	call   801021b9 <namecmp>
80105817:	83 c4 10             	add    $0x10,%esp
8010581a:	85 c0                	test   %eax,%eax
8010581c:	0f 84 2d 01 00 00    	je     8010594f <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105822:	83 ec 04             	sub    $0x4,%esp
80105825:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105828:	50                   	push   %eax
80105829:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010582c:	50                   	push   %eax
8010582d:	ff 75 f4             	push   -0xc(%ebp)
80105830:	e8 9f c9 ff ff       	call   801021d4 <dirlookup>
80105835:	83 c4 10             	add    $0x10,%esp
80105838:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010583b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010583f:	0f 84 0d 01 00 00    	je     80105952 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105845:	83 ec 0c             	sub    $0xc,%esp
80105848:	ff 75 f0             	push   -0x10(%ebp)
8010584b:	e8 a2 c1 ff ff       	call   801019f2 <ilock>
80105850:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105853:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105856:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010585a:	66 85 c0             	test   %ax,%ax
8010585d:	7f 0d                	jg     8010586c <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010585f:	83 ec 0c             	sub    $0xc,%esp
80105862:	68 b9 a8 10 80       	push   $0x8010a8b9
80105867:	e8 3d ad ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010586c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105873:	66 83 f8 01          	cmp    $0x1,%ax
80105877:	75 25                	jne    8010589e <sys_unlink+0x117>
80105879:	83 ec 0c             	sub    $0xc,%esp
8010587c:	ff 75 f0             	push   -0x10(%ebp)
8010587f:	e8 a0 fe ff ff       	call   80105724 <isdirempty>
80105884:	83 c4 10             	add    $0x10,%esp
80105887:	85 c0                	test   %eax,%eax
80105889:	75 13                	jne    8010589e <sys_unlink+0x117>
    iunlockput(ip);
8010588b:	83 ec 0c             	sub    $0xc,%esp
8010588e:	ff 75 f0             	push   -0x10(%ebp)
80105891:	e8 8d c3 ff ff       	call   80101c23 <iunlockput>
80105896:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105899:	e9 b5 00 00 00       	jmp    80105953 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
8010589e:	83 ec 04             	sub    $0x4,%esp
801058a1:	6a 10                	push   $0x10
801058a3:	6a 00                	push   $0x0
801058a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058a8:	50                   	push   %eax
801058a9:	e8 cf f5 ff ff       	call   80104e7d <memset>
801058ae:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801058b1:	8b 45 c8             	mov    -0x38(%ebp),%eax
801058b4:	6a 10                	push   $0x10
801058b6:	50                   	push   %eax
801058b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801058ba:	50                   	push   %eax
801058bb:	ff 75 f4             	push   -0xc(%ebp)
801058be:	e8 70 c7 ff ff       	call   80102033 <writei>
801058c3:	83 c4 10             	add    $0x10,%esp
801058c6:	83 f8 10             	cmp    $0x10,%eax
801058c9:	74 0d                	je     801058d8 <sys_unlink+0x151>
    panic("unlink: writei");
801058cb:	83 ec 0c             	sub    $0xc,%esp
801058ce:	68 cb a8 10 80       	push   $0x8010a8cb
801058d3:	e8 d1 ac ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801058d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058db:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801058df:	66 83 f8 01          	cmp    $0x1,%ax
801058e3:	75 21                	jne    80105906 <sys_unlink+0x17f>
    dp->nlink--;
801058e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e8:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801058ec:	83 e8 01             	sub    $0x1,%eax
801058ef:	89 c2                	mov    %eax,%edx
801058f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f4:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801058f8:	83 ec 0c             	sub    $0xc,%esp
801058fb:	ff 75 f4             	push   -0xc(%ebp)
801058fe:	e8 12 bf ff ff       	call   80101815 <iupdate>
80105903:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105906:	83 ec 0c             	sub    $0xc,%esp
80105909:	ff 75 f4             	push   -0xc(%ebp)
8010590c:	e8 12 c3 ff ff       	call   80101c23 <iunlockput>
80105911:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105914:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105917:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010591b:	83 e8 01             	sub    $0x1,%eax
8010591e:	89 c2                	mov    %eax,%edx
80105920:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105923:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105927:	83 ec 0c             	sub    $0xc,%esp
8010592a:	ff 75 f0             	push   -0x10(%ebp)
8010592d:	e8 e3 be ff ff       	call   80101815 <iupdate>
80105932:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105935:	83 ec 0c             	sub    $0xc,%esp
80105938:	ff 75 f0             	push   -0x10(%ebp)
8010593b:	e8 e3 c2 ff ff       	call   80101c23 <iunlockput>
80105940:	83 c4 10             	add    $0x10,%esp

  end_op();
80105943:	e8 64 dc ff ff       	call   801035ac <end_op>

  return 0;
80105948:	b8 00 00 00 00       	mov    $0x0,%eax
8010594d:	eb 1c                	jmp    8010596b <sys_unlink+0x1e4>
    goto bad;
8010594f:	90                   	nop
80105950:	eb 01                	jmp    80105953 <sys_unlink+0x1cc>
    goto bad;
80105952:	90                   	nop

bad:
  iunlockput(dp);
80105953:	83 ec 0c             	sub    $0xc,%esp
80105956:	ff 75 f4             	push   -0xc(%ebp)
80105959:	e8 c5 c2 ff ff       	call   80101c23 <iunlockput>
8010595e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105961:	e8 46 dc ff ff       	call   801035ac <end_op>
  return -1;
80105966:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010596b:	c9                   	leave
8010596c:	c3                   	ret

8010596d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010596d:	55                   	push   %ebp
8010596e:	89 e5                	mov    %esp,%ebp
80105970:	83 ec 38             	sub    $0x38,%esp
80105973:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105976:	8b 55 10             	mov    0x10(%ebp),%edx
80105979:	8b 45 14             	mov    0x14(%ebp),%eax
8010597c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105980:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105984:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105988:	83 ec 08             	sub    $0x8,%esp
8010598b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010598e:	50                   	push   %eax
8010598f:	ff 75 08             	push   0x8(%ebp)
80105992:	e8 aa cb ff ff       	call   80102541 <nameiparent>
80105997:	83 c4 10             	add    $0x10,%esp
8010599a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010599d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059a1:	75 0a                	jne    801059ad <create+0x40>
    return 0;
801059a3:	b8 00 00 00 00       	mov    $0x0,%eax
801059a8:	e9 90 01 00 00       	jmp    80105b3d <create+0x1d0>
  ilock(dp);
801059ad:	83 ec 0c             	sub    $0xc,%esp
801059b0:	ff 75 f4             	push   -0xc(%ebp)
801059b3:	e8 3a c0 ff ff       	call   801019f2 <ilock>
801059b8:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801059bb:	83 ec 04             	sub    $0x4,%esp
801059be:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059c1:	50                   	push   %eax
801059c2:	8d 45 de             	lea    -0x22(%ebp),%eax
801059c5:	50                   	push   %eax
801059c6:	ff 75 f4             	push   -0xc(%ebp)
801059c9:	e8 06 c8 ff ff       	call   801021d4 <dirlookup>
801059ce:	83 c4 10             	add    $0x10,%esp
801059d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059d8:	74 50                	je     80105a2a <create+0xbd>
    iunlockput(dp);
801059da:	83 ec 0c             	sub    $0xc,%esp
801059dd:	ff 75 f4             	push   -0xc(%ebp)
801059e0:	e8 3e c2 ff ff       	call   80101c23 <iunlockput>
801059e5:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801059e8:	83 ec 0c             	sub    $0xc,%esp
801059eb:	ff 75 f0             	push   -0x10(%ebp)
801059ee:	e8 ff bf ff ff       	call   801019f2 <ilock>
801059f3:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801059f6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801059fb:	75 15                	jne    80105a12 <create+0xa5>
801059fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a00:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a04:	66 83 f8 02          	cmp    $0x2,%ax
80105a08:	75 08                	jne    80105a12 <create+0xa5>
      return ip;
80105a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0d:	e9 2b 01 00 00       	jmp    80105b3d <create+0x1d0>
    iunlockput(ip);
80105a12:	83 ec 0c             	sub    $0xc,%esp
80105a15:	ff 75 f0             	push   -0x10(%ebp)
80105a18:	e8 06 c2 ff ff       	call   80101c23 <iunlockput>
80105a1d:	83 c4 10             	add    $0x10,%esp
    return 0;
80105a20:	b8 00 00 00 00       	mov    $0x0,%eax
80105a25:	e9 13 01 00 00       	jmp    80105b3d <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105a2a:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a31:	8b 00                	mov    (%eax),%eax
80105a33:	83 ec 08             	sub    $0x8,%esp
80105a36:	52                   	push   %edx
80105a37:	50                   	push   %eax
80105a38:	e8 02 bd ff ff       	call   8010173f <ialloc>
80105a3d:	83 c4 10             	add    $0x10,%esp
80105a40:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a47:	75 0d                	jne    80105a56 <create+0xe9>
    panic("create: ialloc");
80105a49:	83 ec 0c             	sub    $0xc,%esp
80105a4c:	68 da a8 10 80       	push   $0x8010a8da
80105a51:	e8 53 ab ff ff       	call   801005a9 <panic>

  ilock(ip);
80105a56:	83 ec 0c             	sub    $0xc,%esp
80105a59:	ff 75 f0             	push   -0x10(%ebp)
80105a5c:	e8 91 bf ff ff       	call   801019f2 <ilock>
80105a61:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a67:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105a6b:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a72:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105a76:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7d:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105a83:	83 ec 0c             	sub    $0xc,%esp
80105a86:	ff 75 f0             	push   -0x10(%ebp)
80105a89:	e8 87 bd ff ff       	call   80101815 <iupdate>
80105a8e:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105a91:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105a96:	75 6a                	jne    80105b02 <create+0x195>
    dp->nlink++;  // for ".."
80105a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105a9f:	83 c0 01             	add    $0x1,%eax
80105aa2:	89 c2                	mov    %eax,%edx
80105aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa7:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105aab:	83 ec 0c             	sub    $0xc,%esp
80105aae:	ff 75 f4             	push   -0xc(%ebp)
80105ab1:	e8 5f bd ff ff       	call   80101815 <iupdate>
80105ab6:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abc:	8b 40 04             	mov    0x4(%eax),%eax
80105abf:	83 ec 04             	sub    $0x4,%esp
80105ac2:	50                   	push   %eax
80105ac3:	68 b4 a8 10 80       	push   $0x8010a8b4
80105ac8:	ff 75 f0             	push   -0x10(%ebp)
80105acb:	e8 be c7 ff ff       	call   8010228e <dirlink>
80105ad0:	83 c4 10             	add    $0x10,%esp
80105ad3:	85 c0                	test   %eax,%eax
80105ad5:	78 1e                	js     80105af5 <create+0x188>
80105ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ada:	8b 40 04             	mov    0x4(%eax),%eax
80105add:	83 ec 04             	sub    $0x4,%esp
80105ae0:	50                   	push   %eax
80105ae1:	68 b6 a8 10 80       	push   $0x8010a8b6
80105ae6:	ff 75 f0             	push   -0x10(%ebp)
80105ae9:	e8 a0 c7 ff ff       	call   8010228e <dirlink>
80105aee:	83 c4 10             	add    $0x10,%esp
80105af1:	85 c0                	test   %eax,%eax
80105af3:	79 0d                	jns    80105b02 <create+0x195>
      panic("create dots");
80105af5:	83 ec 0c             	sub    $0xc,%esp
80105af8:	68 e9 a8 10 80       	push   $0x8010a8e9
80105afd:	e8 a7 aa ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b05:	8b 40 04             	mov    0x4(%eax),%eax
80105b08:	83 ec 04             	sub    $0x4,%esp
80105b0b:	50                   	push   %eax
80105b0c:	8d 45 de             	lea    -0x22(%ebp),%eax
80105b0f:	50                   	push   %eax
80105b10:	ff 75 f4             	push   -0xc(%ebp)
80105b13:	e8 76 c7 ff ff       	call   8010228e <dirlink>
80105b18:	83 c4 10             	add    $0x10,%esp
80105b1b:	85 c0                	test   %eax,%eax
80105b1d:	79 0d                	jns    80105b2c <create+0x1bf>
    panic("create: dirlink");
80105b1f:	83 ec 0c             	sub    $0xc,%esp
80105b22:	68 f5 a8 10 80       	push   $0x8010a8f5
80105b27:	e8 7d aa ff ff       	call   801005a9 <panic>

  iunlockput(dp);
80105b2c:	83 ec 0c             	sub    $0xc,%esp
80105b2f:	ff 75 f4             	push   -0xc(%ebp)
80105b32:	e8 ec c0 ff ff       	call   80101c23 <iunlockput>
80105b37:	83 c4 10             	add    $0x10,%esp

  return ip;
80105b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105b3d:	c9                   	leave
80105b3e:	c3                   	ret

80105b3f <sys_open>:

int
sys_open(void)
{
80105b3f:	55                   	push   %ebp
80105b40:	89 e5                	mov    %esp,%ebp
80105b42:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105b45:	83 ec 08             	sub    $0x8,%esp
80105b48:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b4b:	50                   	push   %eax
80105b4c:	6a 00                	push   $0x0
80105b4e:	e8 ea f6 ff ff       	call   8010523d <argstr>
80105b53:	83 c4 10             	add    $0x10,%esp
80105b56:	85 c0                	test   %eax,%eax
80105b58:	78 15                	js     80105b6f <sys_open+0x30>
80105b5a:	83 ec 08             	sub    $0x8,%esp
80105b5d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b60:	50                   	push   %eax
80105b61:	6a 01                	push   $0x1
80105b63:	e8 40 f6 ff ff       	call   801051a8 <argint>
80105b68:	83 c4 10             	add    $0x10,%esp
80105b6b:	85 c0                	test   %eax,%eax
80105b6d:	79 0a                	jns    80105b79 <sys_open+0x3a>
    return -1;
80105b6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b74:	e9 61 01 00 00       	jmp    80105cda <sys_open+0x19b>

  begin_op();
80105b79:	e8 a2 d9 ff ff       	call   80103520 <begin_op>

  if(omode & O_CREATE){
80105b7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b81:	25 00 02 00 00       	and    $0x200,%eax
80105b86:	85 c0                	test   %eax,%eax
80105b88:	74 2a                	je     80105bb4 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105b8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b8d:	6a 00                	push   $0x0
80105b8f:	6a 00                	push   $0x0
80105b91:	6a 02                	push   $0x2
80105b93:	50                   	push   %eax
80105b94:	e8 d4 fd ff ff       	call   8010596d <create>
80105b99:	83 c4 10             	add    $0x10,%esp
80105b9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105b9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba3:	75 75                	jne    80105c1a <sys_open+0xdb>
      end_op();
80105ba5:	e8 02 da ff ff       	call   801035ac <end_op>
      return -1;
80105baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105baf:	e9 26 01 00 00       	jmp    80105cda <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105bb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bb7:	83 ec 0c             	sub    $0xc,%esp
80105bba:	50                   	push   %eax
80105bbb:	e8 65 c9 ff ff       	call   80102525 <namei>
80105bc0:	83 c4 10             	add    $0x10,%esp
80105bc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bca:	75 0f                	jne    80105bdb <sys_open+0x9c>
      end_op();
80105bcc:	e8 db d9 ff ff       	call   801035ac <end_op>
      return -1;
80105bd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd6:	e9 ff 00 00 00       	jmp    80105cda <sys_open+0x19b>
    }
    ilock(ip);
80105bdb:	83 ec 0c             	sub    $0xc,%esp
80105bde:	ff 75 f4             	push   -0xc(%ebp)
80105be1:	e8 0c be ff ff       	call   801019f2 <ilock>
80105be6:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105bf0:	66 83 f8 01          	cmp    $0x1,%ax
80105bf4:	75 24                	jne    80105c1a <sys_open+0xdb>
80105bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bf9:	85 c0                	test   %eax,%eax
80105bfb:	74 1d                	je     80105c1a <sys_open+0xdb>
      iunlockput(ip);
80105bfd:	83 ec 0c             	sub    $0xc,%esp
80105c00:	ff 75 f4             	push   -0xc(%ebp)
80105c03:	e8 1b c0 ff ff       	call   80101c23 <iunlockput>
80105c08:	83 c4 10             	add    $0x10,%esp
      end_op();
80105c0b:	e8 9c d9 ff ff       	call   801035ac <end_op>
      return -1;
80105c10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c15:	e9 c0 00 00 00       	jmp    80105cda <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105c1a:	e8 c8 b3 ff ff       	call   80100fe7 <filealloc>
80105c1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c26:	74 17                	je     80105c3f <sys_open+0x100>
80105c28:	83 ec 0c             	sub    $0xc,%esp
80105c2b:	ff 75 f0             	push   -0x10(%ebp)
80105c2e:	e8 33 f7 ff ff       	call   80105366 <fdalloc>
80105c33:	83 c4 10             	add    $0x10,%esp
80105c36:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105c39:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105c3d:	79 2e                	jns    80105c6d <sys_open+0x12e>
    if(f)
80105c3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c43:	74 0e                	je     80105c53 <sys_open+0x114>
      fileclose(f);
80105c45:	83 ec 0c             	sub    $0xc,%esp
80105c48:	ff 75 f0             	push   -0x10(%ebp)
80105c4b:	e8 55 b4 ff ff       	call   801010a5 <fileclose>
80105c50:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105c53:	83 ec 0c             	sub    $0xc,%esp
80105c56:	ff 75 f4             	push   -0xc(%ebp)
80105c59:	e8 c5 bf ff ff       	call   80101c23 <iunlockput>
80105c5e:	83 c4 10             	add    $0x10,%esp
    end_op();
80105c61:	e8 46 d9 ff ff       	call   801035ac <end_op>
    return -1;
80105c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c6b:	eb 6d                	jmp    80105cda <sys_open+0x19b>
  }
  iunlock(ip);
80105c6d:	83 ec 0c             	sub    $0xc,%esp
80105c70:	ff 75 f4             	push   -0xc(%ebp)
80105c73:	e8 8d be ff ff       	call   80101b05 <iunlock>
80105c78:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c7b:	e8 2c d9 ff ff       	call   801035ac <end_op>

  f->type = FD_INODE;
80105c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c83:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c8f:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c95:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105c9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c9f:	83 e0 01             	and    $0x1,%eax
80105ca2:	85 c0                	test   %eax,%eax
80105ca4:	0f 94 c0             	sete   %al
80105ca7:	89 c2                	mov    %eax,%edx
80105ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cac:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105caf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cb2:	83 e0 01             	and    $0x1,%eax
80105cb5:	85 c0                	test   %eax,%eax
80105cb7:	75 0a                	jne    80105cc3 <sys_open+0x184>
80105cb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cbc:	83 e0 02             	and    $0x2,%eax
80105cbf:	85 c0                	test   %eax,%eax
80105cc1:	74 07                	je     80105cca <sys_open+0x18b>
80105cc3:	b8 01 00 00 00       	mov    $0x1,%eax
80105cc8:	eb 05                	jmp    80105ccf <sys_open+0x190>
80105cca:	b8 00 00 00 00       	mov    $0x0,%eax
80105ccf:	89 c2                	mov    %eax,%edx
80105cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cd4:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105cd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105cda:	c9                   	leave
80105cdb:	c3                   	ret

80105cdc <sys_mkdir>:

int
sys_mkdir(void)
{
80105cdc:	55                   	push   %ebp
80105cdd:	89 e5                	mov    %esp,%ebp
80105cdf:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105ce2:	e8 39 d8 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105ce7:	83 ec 08             	sub    $0x8,%esp
80105cea:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ced:	50                   	push   %eax
80105cee:	6a 00                	push   $0x0
80105cf0:	e8 48 f5 ff ff       	call   8010523d <argstr>
80105cf5:	83 c4 10             	add    $0x10,%esp
80105cf8:	85 c0                	test   %eax,%eax
80105cfa:	78 1b                	js     80105d17 <sys_mkdir+0x3b>
80105cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cff:	6a 00                	push   $0x0
80105d01:	6a 00                	push   $0x0
80105d03:	6a 01                	push   $0x1
80105d05:	50                   	push   %eax
80105d06:	e8 62 fc ff ff       	call   8010596d <create>
80105d0b:	83 c4 10             	add    $0x10,%esp
80105d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d15:	75 0c                	jne    80105d23 <sys_mkdir+0x47>
    end_op();
80105d17:	e8 90 d8 ff ff       	call   801035ac <end_op>
    return -1;
80105d1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d21:	eb 18                	jmp    80105d3b <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105d23:	83 ec 0c             	sub    $0xc,%esp
80105d26:	ff 75 f4             	push   -0xc(%ebp)
80105d29:	e8 f5 be ff ff       	call   80101c23 <iunlockput>
80105d2e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d31:	e8 76 d8 ff ff       	call   801035ac <end_op>
  return 0;
80105d36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d3b:	c9                   	leave
80105d3c:	c3                   	ret

80105d3d <sys_mknod>:

int
sys_mknod(void)
{
80105d3d:	55                   	push   %ebp
80105d3e:	89 e5                	mov    %esp,%ebp
80105d40:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105d43:	e8 d8 d7 ff ff       	call   80103520 <begin_op>
  if((argstr(0, &path)) < 0 ||
80105d48:	83 ec 08             	sub    $0x8,%esp
80105d4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d4e:	50                   	push   %eax
80105d4f:	6a 00                	push   $0x0
80105d51:	e8 e7 f4 ff ff       	call   8010523d <argstr>
80105d56:	83 c4 10             	add    $0x10,%esp
80105d59:	85 c0                	test   %eax,%eax
80105d5b:	78 4f                	js     80105dac <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105d5d:	83 ec 08             	sub    $0x8,%esp
80105d60:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d63:	50                   	push   %eax
80105d64:	6a 01                	push   $0x1
80105d66:	e8 3d f4 ff ff       	call   801051a8 <argint>
80105d6b:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105d6e:	85 c0                	test   %eax,%eax
80105d70:	78 3a                	js     80105dac <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105d72:	83 ec 08             	sub    $0x8,%esp
80105d75:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105d78:	50                   	push   %eax
80105d79:	6a 02                	push   $0x2
80105d7b:	e8 28 f4 ff ff       	call   801051a8 <argint>
80105d80:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105d83:	85 c0                	test   %eax,%eax
80105d85:	78 25                	js     80105dac <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105d87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105d8a:	0f bf c8             	movswl %ax,%ecx
80105d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105d90:	0f bf d0             	movswl %ax,%edx
80105d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d96:	51                   	push   %ecx
80105d97:	52                   	push   %edx
80105d98:	6a 03                	push   $0x3
80105d9a:	50                   	push   %eax
80105d9b:	e8 cd fb ff ff       	call   8010596d <create>
80105da0:	83 c4 10             	add    $0x10,%esp
80105da3:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
80105da6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105daa:	75 0c                	jne    80105db8 <sys_mknod+0x7b>
    end_op();
80105dac:	e8 fb d7 ff ff       	call   801035ac <end_op>
    return -1;
80105db1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db6:	eb 18                	jmp    80105dd0 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105db8:	83 ec 0c             	sub    $0xc,%esp
80105dbb:	ff 75 f4             	push   -0xc(%ebp)
80105dbe:	e8 60 be ff ff       	call   80101c23 <iunlockput>
80105dc3:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dc6:	e8 e1 d7 ff ff       	call   801035ac <end_op>
  return 0;
80105dcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dd0:	c9                   	leave
80105dd1:	c3                   	ret

80105dd2 <sys_chdir>:

int
sys_chdir(void)
{
80105dd2:	55                   	push   %ebp
80105dd3:	89 e5                	mov    %esp,%ebp
80105dd5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105dd8:	e8 35 e1 ff ff       	call   80103f12 <myproc>
80105ddd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80105de0:	e8 3b d7 ff ff       	call   80103520 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105de5:	83 ec 08             	sub    $0x8,%esp
80105de8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105deb:	50                   	push   %eax
80105dec:	6a 00                	push   $0x0
80105dee:	e8 4a f4 ff ff       	call   8010523d <argstr>
80105df3:	83 c4 10             	add    $0x10,%esp
80105df6:	85 c0                	test   %eax,%eax
80105df8:	78 18                	js     80105e12 <sys_chdir+0x40>
80105dfa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105dfd:	83 ec 0c             	sub    $0xc,%esp
80105e00:	50                   	push   %eax
80105e01:	e8 1f c7 ff ff       	call   80102525 <namei>
80105e06:	83 c4 10             	add    $0x10,%esp
80105e09:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e10:	75 0c                	jne    80105e1e <sys_chdir+0x4c>
    end_op();
80105e12:	e8 95 d7 ff ff       	call   801035ac <end_op>
    return -1;
80105e17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1c:	eb 68                	jmp    80105e86 <sys_chdir+0xb4>
  }
  ilock(ip);
80105e1e:	83 ec 0c             	sub    $0xc,%esp
80105e21:	ff 75 f0             	push   -0x10(%ebp)
80105e24:	e8 c9 bb ff ff       	call   801019f2 <ilock>
80105e29:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105e33:	66 83 f8 01          	cmp    $0x1,%ax
80105e37:	74 1a                	je     80105e53 <sys_chdir+0x81>
    iunlockput(ip);
80105e39:	83 ec 0c             	sub    $0xc,%esp
80105e3c:	ff 75 f0             	push   -0x10(%ebp)
80105e3f:	e8 df bd ff ff       	call   80101c23 <iunlockput>
80105e44:	83 c4 10             	add    $0x10,%esp
    end_op();
80105e47:	e8 60 d7 ff ff       	call   801035ac <end_op>
    return -1;
80105e4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e51:	eb 33                	jmp    80105e86 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105e53:	83 ec 0c             	sub    $0xc,%esp
80105e56:	ff 75 f0             	push   -0x10(%ebp)
80105e59:	e8 a7 bc ff ff       	call   80101b05 <iunlock>
80105e5e:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e64:	8b 40 68             	mov    0x68(%eax),%eax
80105e67:	83 ec 0c             	sub    $0xc,%esp
80105e6a:	50                   	push   %eax
80105e6b:	e8 e3 bc ff ff       	call   80101b53 <iput>
80105e70:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e73:	e8 34 d7 ff ff       	call   801035ac <end_op>
  curproc->cwd = ip;
80105e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e7e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105e81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e86:	c9                   	leave
80105e87:	c3                   	ret

80105e88 <sys_exec>:

int
sys_exec(void)
{
80105e88:	55                   	push   %ebp
80105e89:	89 e5                	mov    %esp,%ebp
80105e8b:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105e91:	83 ec 08             	sub    $0x8,%esp
80105e94:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e97:	50                   	push   %eax
80105e98:	6a 00                	push   $0x0
80105e9a:	e8 9e f3 ff ff       	call   8010523d <argstr>
80105e9f:	83 c4 10             	add    $0x10,%esp
80105ea2:	85 c0                	test   %eax,%eax
80105ea4:	78 18                	js     80105ebe <sys_exec+0x36>
80105ea6:	83 ec 08             	sub    $0x8,%esp
80105ea9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105eaf:	50                   	push   %eax
80105eb0:	6a 01                	push   $0x1
80105eb2:	e8 f1 f2 ff ff       	call   801051a8 <argint>
80105eb7:	83 c4 10             	add    $0x10,%esp
80105eba:	85 c0                	test   %eax,%eax
80105ebc:	79 0a                	jns    80105ec8 <sys_exec+0x40>
    return -1;
80105ebe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec3:	e9 c6 00 00 00       	jmp    80105f8e <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105ec8:	83 ec 04             	sub    $0x4,%esp
80105ecb:	68 80 00 00 00       	push   $0x80
80105ed0:	6a 00                	push   $0x0
80105ed2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ed8:	50                   	push   %eax
80105ed9:	e8 9f ef ff ff       	call   80104e7d <memset>
80105ede:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105ee1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eeb:	83 f8 1f             	cmp    $0x1f,%eax
80105eee:	76 0a                	jbe    80105efa <sys_exec+0x72>
      return -1;
80105ef0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef5:	e9 94 00 00 00       	jmp    80105f8e <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efd:	c1 e0 02             	shl    $0x2,%eax
80105f00:	89 c2                	mov    %eax,%edx
80105f02:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105f08:	01 c2                	add    %eax,%edx
80105f0a:	83 ec 08             	sub    $0x8,%esp
80105f0d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105f13:	50                   	push   %eax
80105f14:	52                   	push   %edx
80105f15:	e8 ed f1 ff ff       	call   80105107 <fetchint>
80105f1a:	83 c4 10             	add    $0x10,%esp
80105f1d:	85 c0                	test   %eax,%eax
80105f1f:	79 07                	jns    80105f28 <sys_exec+0xa0>
      return -1;
80105f21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f26:	eb 66                	jmp    80105f8e <sys_exec+0x106>
    if(uarg == 0){
80105f28:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f2e:	85 c0                	test   %eax,%eax
80105f30:	75 27                	jne    80105f59 <sys_exec+0xd1>
      argv[i] = 0;
80105f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f35:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105f3c:	00 00 00 00 
      break;
80105f40:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f44:	83 ec 08             	sub    $0x8,%esp
80105f47:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105f4d:	52                   	push   %edx
80105f4e:	50                   	push   %eax
80105f4f:	e8 36 ac ff ff       	call   80100b8a <exec>
80105f54:	83 c4 10             	add    $0x10,%esp
80105f57:	eb 35                	jmp    80105f8e <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105f59:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105f5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f62:	c1 e2 02             	shl    $0x2,%edx
80105f65:	01 c2                	add    %eax,%edx
80105f67:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105f6d:	83 ec 08             	sub    $0x8,%esp
80105f70:	52                   	push   %edx
80105f71:	50                   	push   %eax
80105f72:	e8 cf f1 ff ff       	call   80105146 <fetchstr>
80105f77:	83 c4 10             	add    $0x10,%esp
80105f7a:	85 c0                	test   %eax,%eax
80105f7c:	79 07                	jns    80105f85 <sys_exec+0xfd>
      return -1;
80105f7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f83:	eb 09                	jmp    80105f8e <sys_exec+0x106>
  for(i=0;; i++){
80105f85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105f89:	e9 5a ff ff ff       	jmp    80105ee8 <sys_exec+0x60>
}
80105f8e:	c9                   	leave
80105f8f:	c3                   	ret

80105f90 <sys_pipe>:

int
sys_pipe(void)
{
80105f90:	55                   	push   %ebp
80105f91:	89 e5                	mov    %esp,%ebp
80105f93:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105f96:	83 ec 04             	sub    $0x4,%esp
80105f99:	6a 08                	push   $0x8
80105f9b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f9e:	50                   	push   %eax
80105f9f:	6a 00                	push   $0x0
80105fa1:	e8 2f f2 ff ff       	call   801051d5 <argptr>
80105fa6:	83 c4 10             	add    $0x10,%esp
80105fa9:	85 c0                	test   %eax,%eax
80105fab:	79 0a                	jns    80105fb7 <sys_pipe+0x27>
    return -1;
80105fad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb2:	e9 ae 00 00 00       	jmp    80106065 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105fb7:	83 ec 08             	sub    $0x8,%esp
80105fba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fbd:	50                   	push   %eax
80105fbe:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fc1:	50                   	push   %eax
80105fc2:	e8 88 da ff ff       	call   80103a4f <pipealloc>
80105fc7:	83 c4 10             	add    $0x10,%esp
80105fca:	85 c0                	test   %eax,%eax
80105fcc:	79 0a                	jns    80105fd8 <sys_pipe+0x48>
    return -1;
80105fce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd3:	e9 8d 00 00 00       	jmp    80106065 <sys_pipe+0xd5>
  fd0 = -1;
80105fd8:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105fdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fe2:	83 ec 0c             	sub    $0xc,%esp
80105fe5:	50                   	push   %eax
80105fe6:	e8 7b f3 ff ff       	call   80105366 <fdalloc>
80105feb:	83 c4 10             	add    $0x10,%esp
80105fee:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ff1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ff5:	78 18                	js     8010600f <sys_pipe+0x7f>
80105ff7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ffa:	83 ec 0c             	sub    $0xc,%esp
80105ffd:	50                   	push   %eax
80105ffe:	e8 63 f3 ff ff       	call   80105366 <fdalloc>
80106003:	83 c4 10             	add    $0x10,%esp
80106006:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106009:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010600d:	79 3e                	jns    8010604d <sys_pipe+0xbd>
    if(fd0 >= 0)
8010600f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106013:	78 13                	js     80106028 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80106015:	e8 f8 de ff ff       	call   80103f12 <myproc>
8010601a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010601d:	83 c2 08             	add    $0x8,%edx
80106020:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106027:	00 
    fileclose(rf);
80106028:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010602b:	83 ec 0c             	sub    $0xc,%esp
8010602e:	50                   	push   %eax
8010602f:	e8 71 b0 ff ff       	call   801010a5 <fileclose>
80106034:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106037:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010603a:	83 ec 0c             	sub    $0xc,%esp
8010603d:	50                   	push   %eax
8010603e:	e8 62 b0 ff ff       	call   801010a5 <fileclose>
80106043:	83 c4 10             	add    $0x10,%esp
    return -1;
80106046:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010604b:	eb 18                	jmp    80106065 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
8010604d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106050:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106053:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106055:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106058:	8d 50 04             	lea    0x4(%eax),%edx
8010605b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605e:	89 02                	mov    %eax,(%edx)
  return 0;
80106060:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106065:	c9                   	leave
80106066:	c3                   	ret

80106067 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106067:	55                   	push   %ebp
80106068:	89 e5                	mov    %esp,%ebp
8010606a:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010606d:	e8 9f e1 ff ff       	call   80104211 <fork>
}
80106072:	c9                   	leave
80106073:	c3                   	ret

80106074 <sys_exit>:

int
sys_exit(void)
{
80106074:	55                   	push   %ebp
80106075:	89 e5                	mov    %esp,%ebp
80106077:	83 ec 08             	sub    $0x8,%esp
  exit();
8010607a:	e8 0b e3 ff ff       	call   8010438a <exit>
  return 0;  // not reached
8010607f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106084:	c9                   	leave
80106085:	c3                   	ret

80106086 <sys_wait>:

int
sys_wait(void)
{
80106086:	55                   	push   %ebp
80106087:	89 e5                	mov    %esp,%ebp
80106089:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010608c:	e8 19 e4 ff ff       	call   801044aa <wait>
}
80106091:	c9                   	leave
80106092:	c3                   	ret

80106093 <sys_kill>:

int
sys_kill(void)
{
80106093:	55                   	push   %ebp
80106094:	89 e5                	mov    %esp,%ebp
80106096:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106099:	83 ec 08             	sub    $0x8,%esp
8010609c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010609f:	50                   	push   %eax
801060a0:	6a 00                	push   $0x0
801060a2:	e8 01 f1 ff ff       	call   801051a8 <argint>
801060a7:	83 c4 10             	add    $0x10,%esp
801060aa:	85 c0                	test   %eax,%eax
801060ac:	79 07                	jns    801060b5 <sys_kill+0x22>
    return -1;
801060ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b3:	eb 0f                	jmp    801060c4 <sys_kill+0x31>
  return kill(pid);
801060b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b8:	83 ec 0c             	sub    $0xc,%esp
801060bb:	50                   	push   %eax
801060bc:	e8 18 e8 ff ff       	call   801048d9 <kill>
801060c1:	83 c4 10             	add    $0x10,%esp
}
801060c4:	c9                   	leave
801060c5:	c3                   	ret

801060c6 <sys_getpid>:

int
sys_getpid(void)
{
801060c6:	55                   	push   %ebp
801060c7:	89 e5                	mov    %esp,%ebp
801060c9:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801060cc:	e8 41 de ff ff       	call   80103f12 <myproc>
801060d1:	8b 40 10             	mov    0x10(%eax),%eax
}
801060d4:	c9                   	leave
801060d5:	c3                   	ret

801060d6 <sys_sbrk>:

int
sys_sbrk(void)
{
801060d6:	55                   	push   %ebp
801060d7:	89 e5                	mov    %esp,%ebp
801060d9:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801060dc:	83 ec 08             	sub    $0x8,%esp
801060df:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060e2:	50                   	push   %eax
801060e3:	6a 00                	push   $0x0
801060e5:	e8 be f0 ff ff       	call   801051a8 <argint>
801060ea:	83 c4 10             	add    $0x10,%esp
801060ed:	85 c0                	test   %eax,%eax
801060ef:	79 07                	jns    801060f8 <sys_sbrk+0x22>
    return -1;
801060f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f6:	eb 27                	jmp    8010611f <sys_sbrk+0x49>
  addr = myproc()->sz;
801060f8:	e8 15 de ff ff       	call   80103f12 <myproc>
801060fd:	8b 00                	mov    (%eax),%eax
801060ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106105:	83 ec 0c             	sub    $0xc,%esp
80106108:	50                   	push   %eax
80106109:	e8 68 e0 ff ff       	call   80104176 <growproc>
8010610e:	83 c4 10             	add    $0x10,%esp
80106111:	85 c0                	test   %eax,%eax
80106113:	79 07                	jns    8010611c <sys_sbrk+0x46>
    return -1;
80106115:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611a:	eb 03                	jmp    8010611f <sys_sbrk+0x49>
  return addr;
8010611c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010611f:	c9                   	leave
80106120:	c3                   	ret

80106121 <sys_sleep>:

int
sys_sleep(void)
{
80106121:	55                   	push   %ebp
80106122:	89 e5                	mov    %esp,%ebp
80106124:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106127:	83 ec 08             	sub    $0x8,%esp
8010612a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010612d:	50                   	push   %eax
8010612e:	6a 00                	push   $0x0
80106130:	e8 73 f0 ff ff       	call   801051a8 <argint>
80106135:	83 c4 10             	add    $0x10,%esp
80106138:	85 c0                	test   %eax,%eax
8010613a:	79 07                	jns    80106143 <sys_sleep+0x22>
    return -1;
8010613c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106141:	eb 76                	jmp    801061b9 <sys_sleep+0x98>
  acquire(&tickslock);
80106143:	83 ec 0c             	sub    $0xc,%esp
80106146:	68 80 9a 11 80       	push   $0x80119a80
8010614b:	e8 b7 ea ff ff       	call   80104c07 <acquire>
80106150:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106153:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
80106158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010615b:	eb 38                	jmp    80106195 <sys_sleep+0x74>
    if(myproc()->killed){
8010615d:	e8 b0 dd ff ff       	call   80103f12 <myproc>
80106162:	8b 40 24             	mov    0x24(%eax),%eax
80106165:	85 c0                	test   %eax,%eax
80106167:	74 17                	je     80106180 <sys_sleep+0x5f>
      release(&tickslock);
80106169:	83 ec 0c             	sub    $0xc,%esp
8010616c:	68 80 9a 11 80       	push   $0x80119a80
80106171:	e8 ff ea ff ff       	call   80104c75 <release>
80106176:	83 c4 10             	add    $0x10,%esp
      return -1;
80106179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617e:	eb 39                	jmp    801061b9 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80106180:	83 ec 08             	sub    $0x8,%esp
80106183:	68 80 9a 11 80       	push   $0x80119a80
80106188:	68 b4 9a 11 80       	push   $0x80119ab4
8010618d:	e8 29 e6 ff ff       	call   801047bb <sleep>
80106192:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106195:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
8010619a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010619d:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061a0:	39 d0                	cmp    %edx,%eax
801061a2:	72 b9                	jb     8010615d <sys_sleep+0x3c>
  }
  release(&tickslock);
801061a4:	83 ec 0c             	sub    $0xc,%esp
801061a7:	68 80 9a 11 80       	push   $0x80119a80
801061ac:	e8 c4 ea ff ff       	call   80104c75 <release>
801061b1:	83 c4 10             	add    $0x10,%esp
  return 0;
801061b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061b9:	c9                   	leave
801061ba:	c3                   	ret

801061bb <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801061bb:	55                   	push   %ebp
801061bc:	89 e5                	mov    %esp,%ebp
801061be:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
801061c1:	83 ec 0c             	sub    $0xc,%esp
801061c4:	68 80 9a 11 80       	push   $0x80119a80
801061c9:	e8 39 ea ff ff       	call   80104c07 <acquire>
801061ce:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801061d1:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
801061d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801061d9:	83 ec 0c             	sub    $0xc,%esp
801061dc:	68 80 9a 11 80       	push   $0x80119a80
801061e1:	e8 8f ea ff ff       	call   80104c75 <release>
801061e6:	83 c4 10             	add    $0x10,%esp
  return xticks;
801061e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801061ec:	c9                   	leave
801061ed:	c3                   	ret

801061ee <sys_uthread_init>:

int
sys_uthread_init(void)
{
801061ee:	55                   	push   %ebp
801061ef:	89 e5                	mov    %esp,%ebp
801061f1:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(0, &addr) < 0) {
801061f4:	83 ec 08             	sub    $0x8,%esp
801061f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061fa:	50                   	push   %eax
801061fb:	6a 00                	push   $0x0
801061fd:	e8 a6 ef ff ff       	call   801051a8 <argint>
80106202:	83 c4 10             	add    $0x10,%esp
80106205:	85 c0                	test   %eax,%eax
80106207:	79 07                	jns    80106210 <sys_uthread_init+0x22>
    return -1;
80106209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620e:	eb 18                	jmp    80106228 <sys_uthread_init+0x3a>
  }
  struct proc *p = myproc();
80106210:	e8 fd dc ff ff       	call   80103f12 <myproc>
80106215:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p->scheduler = (uint)addr;
80106218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621b:	89 c2                	mov    %eax,%edx
8010621d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106220:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
80106223:	b8 00 00 00 00       	mov    $0x0,%eax
80106228:	c9                   	leave
80106229:	c3                   	ret

8010622a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010622a:	1e                   	push   %ds
  pushl %es
8010622b:	06                   	push   %es
  pushl %fs
8010622c:	0f a0                	push   %fs
  pushl %gs
8010622e:	0f a8                	push   %gs
  pushal
80106230:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106231:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106235:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106237:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106239:	54                   	push   %esp
  call trap
8010623a:	e8 d7 01 00 00       	call   80106416 <trap>
  addl $4, %esp
8010623f:	83 c4 04             	add    $0x4,%esp

80106242 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106242:	61                   	popa
  popl %gs
80106243:	0f a9                	pop    %gs
  popl %fs
80106245:	0f a1                	pop    %fs
  popl %es
80106247:	07                   	pop    %es
  popl %ds
80106248:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106249:	83 c4 08             	add    $0x8,%esp
  iret
8010624c:	cf                   	iret

8010624d <lidt>:
{
8010624d:	55                   	push   %ebp
8010624e:	89 e5                	mov    %esp,%ebp
80106250:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106253:	8b 45 0c             	mov    0xc(%ebp),%eax
80106256:	83 e8 01             	sub    $0x1,%eax
80106259:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010625d:	8b 45 08             	mov    0x8(%ebp),%eax
80106260:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106264:	8b 45 08             	mov    0x8(%ebp),%eax
80106267:	c1 e8 10             	shr    $0x10,%eax
8010626a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010626e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106271:	0f 01 18             	lidtl  (%eax)
}
80106274:	90                   	nop
80106275:	c9                   	leave
80106276:	c3                   	ret

80106277 <rcr2>:

static inline uint
rcr2(void)
{
80106277:	55                   	push   %ebp
80106278:	89 e5                	mov    %esp,%ebp
8010627a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010627d:	0f 20 d0             	mov    %cr2,%eax
80106280:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106283:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106286:	c9                   	leave
80106287:	c3                   	ret

80106288 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106288:	55                   	push   %ebp
80106289:	89 e5                	mov    %esp,%ebp
8010628b:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
8010628e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106295:	e9 c3 00 00 00       	jmp    8010635d <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010629a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629d:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
801062a4:	89 c2                	mov    %eax,%edx
801062a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a9:	66 89 14 c5 80 92 11 	mov    %dx,-0x7fee6d80(,%eax,8)
801062b0:	80 
801062b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b4:	66 c7 04 c5 82 92 11 	movw   $0x8,-0x7fee6d7e(,%eax,8)
801062bb:	80 08 00 
801062be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c1:	0f b6 14 c5 84 92 11 	movzbl -0x7fee6d7c(,%eax,8),%edx
801062c8:	80 
801062c9:	83 e2 e0             	and    $0xffffffe0,%edx
801062cc:	88 14 c5 84 92 11 80 	mov    %dl,-0x7fee6d7c(,%eax,8)
801062d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d6:	0f b6 14 c5 84 92 11 	movzbl -0x7fee6d7c(,%eax,8),%edx
801062dd:	80 
801062de:	83 e2 1f             	and    $0x1f,%edx
801062e1:	88 14 c5 84 92 11 80 	mov    %dl,-0x7fee6d7c(,%eax,8)
801062e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062eb:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
801062f2:	80 
801062f3:	83 e2 f0             	and    $0xfffffff0,%edx
801062f6:	83 ca 0e             	or     $0xe,%edx
801062f9:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
80106300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106303:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
8010630a:	80 
8010630b:	83 e2 ef             	and    $0xffffffef,%edx
8010630e:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
80106315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106318:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
8010631f:	80 
80106320:	83 e2 9f             	and    $0xffffff9f,%edx
80106323:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
8010632a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632d:	0f b6 14 c5 85 92 11 	movzbl -0x7fee6d7b(,%eax,8),%edx
80106334:	80 
80106335:	83 ca 80             	or     $0xffffff80,%edx
80106338:	88 14 c5 85 92 11 80 	mov    %dl,-0x7fee6d7b(,%eax,8)
8010633f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106342:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80106349:	c1 e8 10             	shr    $0x10,%eax
8010634c:	89 c2                	mov    %eax,%edx
8010634e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106351:	66 89 14 c5 86 92 11 	mov    %dx,-0x7fee6d7a(,%eax,8)
80106358:	80 
  for(i = 0; i < 256; i++)
80106359:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010635d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106364:	0f 8e 30 ff ff ff    	jle    8010629a <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010636a:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
8010636f:	66 a3 80 94 11 80    	mov    %ax,0x80119480
80106375:	66 c7 05 82 94 11 80 	movw   $0x8,0x80119482
8010637c:	08 00 
8010637e:	0f b6 05 84 94 11 80 	movzbl 0x80119484,%eax
80106385:	83 e0 e0             	and    $0xffffffe0,%eax
80106388:	a2 84 94 11 80       	mov    %al,0x80119484
8010638d:	0f b6 05 84 94 11 80 	movzbl 0x80119484,%eax
80106394:	83 e0 1f             	and    $0x1f,%eax
80106397:	a2 84 94 11 80       	mov    %al,0x80119484
8010639c:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
801063a3:	83 c8 0f             	or     $0xf,%eax
801063a6:	a2 85 94 11 80       	mov    %al,0x80119485
801063ab:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
801063b2:	83 e0 ef             	and    $0xffffffef,%eax
801063b5:	a2 85 94 11 80       	mov    %al,0x80119485
801063ba:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
801063c1:	83 c8 60             	or     $0x60,%eax
801063c4:	a2 85 94 11 80       	mov    %al,0x80119485
801063c9:	0f b6 05 85 94 11 80 	movzbl 0x80119485,%eax
801063d0:	83 c8 80             	or     $0xffffff80,%eax
801063d3:	a2 85 94 11 80       	mov    %al,0x80119485
801063d8:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
801063dd:	c1 e8 10             	shr    $0x10,%eax
801063e0:	66 a3 86 94 11 80    	mov    %ax,0x80119486

  initlock(&tickslock, "time");
801063e6:	83 ec 08             	sub    $0x8,%esp
801063e9:	68 08 a9 10 80       	push   $0x8010a908
801063ee:	68 80 9a 11 80       	push   $0x80119a80
801063f3:	e8 ed e7 ff ff       	call   80104be5 <initlock>
801063f8:	83 c4 10             	add    $0x10,%esp
}
801063fb:	90                   	nop
801063fc:	c9                   	leave
801063fd:	c3                   	ret

801063fe <idtinit>:

void
idtinit(void)
{
801063fe:	55                   	push   %ebp
801063ff:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106401:	68 00 08 00 00       	push   $0x800
80106406:	68 80 92 11 80       	push   $0x80119280
8010640b:	e8 3d fe ff ff       	call   8010624d <lidt>
80106410:	83 c4 08             	add    $0x8,%esp
}
80106413:	90                   	nop
80106414:	c9                   	leave
80106415:	c3                   	ret

80106416 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106416:	55                   	push   %ebp
80106417:	89 e5                	mov    %esp,%ebp
80106419:	57                   	push   %edi
8010641a:	56                   	push   %esi
8010641b:	53                   	push   %ebx
8010641c:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
8010641f:	8b 45 08             	mov    0x8(%ebp),%eax
80106422:	8b 40 30             	mov    0x30(%eax),%eax
80106425:	83 f8 40             	cmp    $0x40,%eax
80106428:	75 3b                	jne    80106465 <trap+0x4f>
    if(myproc()->killed)
8010642a:	e8 e3 da ff ff       	call   80103f12 <myproc>
8010642f:	8b 40 24             	mov    0x24(%eax),%eax
80106432:	85 c0                	test   %eax,%eax
80106434:	74 05                	je     8010643b <trap+0x25>
      exit();
80106436:	e8 4f df ff ff       	call   8010438a <exit>
    myproc()->tf = tf;
8010643b:	e8 d2 da ff ff       	call   80103f12 <myproc>
80106440:	8b 55 08             	mov    0x8(%ebp),%edx
80106443:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106446:	e8 29 ee ff ff       	call   80105274 <syscall>
    if(myproc()->killed)
8010644b:	e8 c2 da ff ff       	call   80103f12 <myproc>
80106450:	8b 40 24             	mov    0x24(%eax),%eax
80106453:	85 c0                	test   %eax,%eax
80106455:	0f 84 8f 02 00 00    	je     801066ea <trap+0x2d4>
      exit();
8010645b:	e8 2a df ff ff       	call   8010438a <exit>
    return;
80106460:	e9 85 02 00 00       	jmp    801066ea <trap+0x2d4>
  }

  switch(tf->trapno){
80106465:	8b 45 08             	mov    0x8(%ebp),%eax
80106468:	8b 40 30             	mov    0x30(%eax),%eax
8010646b:	83 e8 20             	sub    $0x20,%eax
8010646e:	83 f8 1f             	cmp    $0x1f,%eax
80106471:	0f 87 3b 01 00 00    	ja     801065b2 <trap+0x19c>
80106477:	8b 04 85 b0 a9 10 80 	mov    -0x7fef5650(,%eax,4),%eax
8010647e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106480:	e8 fa d9 ff ff       	call   80103e7f <cpuid>
80106485:	85 c0                	test   %eax,%eax
80106487:	75 3d                	jne    801064c6 <trap+0xb0>
      acquire(&tickslock);
80106489:	83 ec 0c             	sub    $0xc,%esp
8010648c:	68 80 9a 11 80       	push   $0x80119a80
80106491:	e8 71 e7 ff ff       	call   80104c07 <acquire>
80106496:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106499:	a1 b4 9a 11 80       	mov    0x80119ab4,%eax
8010649e:	83 c0 01             	add    $0x1,%eax
801064a1:	a3 b4 9a 11 80       	mov    %eax,0x80119ab4
      wakeup(&ticks);
801064a6:	83 ec 0c             	sub    $0xc,%esp
801064a9:	68 b4 9a 11 80       	push   $0x80119ab4
801064ae:	e8 ef e3 ff ff       	call   801048a2 <wakeup>
801064b3:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801064b6:	83 ec 0c             	sub    $0xc,%esp
801064b9:	68 80 9a 11 80       	push   $0x80119a80
801064be:	e8 b2 e7 ff ff       	call   80104c75 <release>
801064c3:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801064c6:	e8 35 cb ff ff       	call   80103000 <lapiceoi>
    // New code for scheduler
    if(myproc() && (tf->cs&3) == DPL_USER) {
801064cb:	e8 42 da ff ff       	call   80103f12 <myproc>
801064d0:	85 c0                	test   %eax,%eax
801064d2:	0f 84 91 01 00 00    	je     80106669 <trap+0x253>
801064d8:	8b 45 08             	mov    0x8(%ebp),%eax
801064db:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801064df:	0f b7 c0             	movzwl %ax,%eax
801064e2:	83 e0 03             	and    $0x3,%eax
801064e5:	83 f8 03             	cmp    $0x3,%eax
801064e8:	0f 85 7b 01 00 00    	jne    80106669 <trap+0x253>
      if(myproc()->state == RUNNING && myproc()->scheduler)
801064ee:	e8 1f da ff ff       	call   80103f12 <myproc>
801064f3:	8b 40 0c             	mov    0xc(%eax),%eax
801064f6:	83 f8 04             	cmp    $0x4,%eax
801064f9:	0f 85 6a 01 00 00    	jne    80106669 <trap+0x253>
801064ff:	e8 0e da ff ff       	call   80103f12 <myproc>
80106504:	8b 40 7c             	mov    0x7c(%eax),%eax
80106507:	85 c0                	test   %eax,%eax
80106509:	0f 84 5a 01 00 00    	je     80106669 <trap+0x253>
      {
        uint ret_addr = tf->eip;
8010650f:	8b 45 08             	mov    0x8(%ebp),%eax
80106512:	8b 40 38             	mov    0x38(%eax),%eax
80106515:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        tf->esp -= 4;
80106518:	8b 45 08             	mov    0x8(%ebp),%eax
8010651b:	8b 40 44             	mov    0x44(%eax),%eax
8010651e:	8d 50 fc             	lea    -0x4(%eax),%edx
80106521:	8b 45 08             	mov    0x8(%ebp),%eax
80106524:	89 50 44             	mov    %edx,0x44(%eax)
        *(uint*)tf->esp = ret_addr;
80106527:	8b 45 08             	mov    0x8(%ebp),%eax
8010652a:	8b 40 44             	mov    0x44(%eax),%eax
8010652d:	89 c2                	mov    %eax,%edx
8010652f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106532:	89 02                	mov    %eax,(%edx)
        tf->eip = myproc()->scheduler;
80106534:	e8 d9 d9 ff ff       	call   80103f12 <myproc>
80106539:	8b 50 7c             	mov    0x7c(%eax),%edx
8010653c:	8b 45 08             	mov    0x8(%ebp),%eax
8010653f:	89 50 38             	mov    %edx,0x38(%eax)
      } 
    }
    break;
80106542:	e9 22 01 00 00       	jmp    80106669 <trap+0x253>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106547:	e8 10 c3 ff ff       	call   8010285c <ideintr>
    lapiceoi();
8010654c:	e8 af ca ff ff       	call   80103000 <lapiceoi>
    break;
80106551:	e9 14 01 00 00       	jmp    8010666a <trap+0x254>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106556:	e8 f0 c8 ff ff       	call   80102e4b <kbdintr>
    lapiceoi();
8010655b:	e8 a0 ca ff ff       	call   80103000 <lapiceoi>
    break;
80106560:	e9 05 01 00 00       	jmp    8010666a <trap+0x254>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106565:	e8 54 03 00 00       	call   801068be <uartintr>
    lapiceoi();
8010656a:	e8 91 ca ff ff       	call   80103000 <lapiceoi>
    break;
8010656f:	e9 f6 00 00 00       	jmp    8010666a <trap+0x254>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106574:	e8 7a 2b 00 00       	call   801090f3 <i8254_intr>
    lapiceoi();
80106579:	e8 82 ca ff ff       	call   80103000 <lapiceoi>
    break;
8010657e:	e9 e7 00 00 00       	jmp    8010666a <trap+0x254>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106583:	8b 45 08             	mov    0x8(%ebp),%eax
80106586:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106589:	8b 45 08             	mov    0x8(%ebp),%eax
8010658c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106590:	0f b7 d8             	movzwl %ax,%ebx
80106593:	e8 e7 d8 ff ff       	call   80103e7f <cpuid>
80106598:	56                   	push   %esi
80106599:	53                   	push   %ebx
8010659a:	50                   	push   %eax
8010659b:	68 10 a9 10 80       	push   $0x8010a910
801065a0:	e8 4f 9e ff ff       	call   801003f4 <cprintf>
801065a5:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801065a8:	e8 53 ca ff ff       	call   80103000 <lapiceoi>
    break;
801065ad:	e9 b8 00 00 00       	jmp    8010666a <trap+0x254>
  
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801065b2:	e8 5b d9 ff ff       	call   80103f12 <myproc>
801065b7:	85 c0                	test   %eax,%eax
801065b9:	74 11                	je     801065cc <trap+0x1b6>
801065bb:	8b 45 08             	mov    0x8(%ebp),%eax
801065be:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801065c2:	0f b7 c0             	movzwl %ax,%eax
801065c5:	83 e0 03             	and    $0x3,%eax
801065c8:	85 c0                	test   %eax,%eax
801065ca:	75 39                	jne    80106605 <trap+0x1ef>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801065cc:	e8 a6 fc ff ff       	call   80106277 <rcr2>
801065d1:	89 c3                	mov    %eax,%ebx
801065d3:	8b 45 08             	mov    0x8(%ebp),%eax
801065d6:	8b 70 38             	mov    0x38(%eax),%esi
801065d9:	e8 a1 d8 ff ff       	call   80103e7f <cpuid>
801065de:	8b 55 08             	mov    0x8(%ebp),%edx
801065e1:	8b 52 30             	mov    0x30(%edx),%edx
801065e4:	83 ec 0c             	sub    $0xc,%esp
801065e7:	53                   	push   %ebx
801065e8:	56                   	push   %esi
801065e9:	50                   	push   %eax
801065ea:	52                   	push   %edx
801065eb:	68 34 a9 10 80       	push   $0x8010a934
801065f0:	e8 ff 9d ff ff       	call   801003f4 <cprintf>
801065f5:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801065f8:	83 ec 0c             	sub    $0xc,%esp
801065fb:	68 66 a9 10 80       	push   $0x8010a966
80106600:	e8 a4 9f ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106605:	e8 6d fc ff ff       	call   80106277 <rcr2>
8010660a:	89 c6                	mov    %eax,%esi
8010660c:	8b 45 08             	mov    0x8(%ebp),%eax
8010660f:	8b 40 38             	mov    0x38(%eax),%eax
80106612:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106615:	e8 65 d8 ff ff       	call   80103e7f <cpuid>
8010661a:	89 c3                	mov    %eax,%ebx
8010661c:	8b 45 08             	mov    0x8(%ebp),%eax
8010661f:	8b 48 34             	mov    0x34(%eax),%ecx
80106622:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80106625:	8b 45 08             	mov    0x8(%ebp),%eax
80106628:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010662b:	e8 e2 d8 ff ff       	call   80103f12 <myproc>
80106630:	8d 50 6c             	lea    0x6c(%eax),%edx
80106633:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106636:	e8 d7 d8 ff ff       	call   80103f12 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010663b:	8b 40 10             	mov    0x10(%eax),%eax
8010663e:	56                   	push   %esi
8010663f:	ff 75 d4             	push   -0x2c(%ebp)
80106642:	53                   	push   %ebx
80106643:	ff 75 d0             	push   -0x30(%ebp)
80106646:	57                   	push   %edi
80106647:	ff 75 cc             	push   -0x34(%ebp)
8010664a:	50                   	push   %eax
8010664b:	68 6c a9 10 80       	push   $0x8010a96c
80106650:	e8 9f 9d ff ff       	call   801003f4 <cprintf>
80106655:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106658:	e8 b5 d8 ff ff       	call   80103f12 <myproc>
8010665d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106664:	eb 04                	jmp    8010666a <trap+0x254>
    break;
80106666:	90                   	nop
80106667:	eb 01                	jmp    8010666a <trap+0x254>
    break;
80106669:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010666a:	e8 a3 d8 ff ff       	call   80103f12 <myproc>
8010666f:	85 c0                	test   %eax,%eax
80106671:	74 23                	je     80106696 <trap+0x280>
80106673:	e8 9a d8 ff ff       	call   80103f12 <myproc>
80106678:	8b 40 24             	mov    0x24(%eax),%eax
8010667b:	85 c0                	test   %eax,%eax
8010667d:	74 17                	je     80106696 <trap+0x280>
8010667f:	8b 45 08             	mov    0x8(%ebp),%eax
80106682:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106686:	0f b7 c0             	movzwl %ax,%eax
80106689:	83 e0 03             	and    $0x3,%eax
8010668c:	83 f8 03             	cmp    $0x3,%eax
8010668f:	75 05                	jne    80106696 <trap+0x280>
    exit();
80106691:	e8 f4 dc ff ff       	call   8010438a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106696:	e8 77 d8 ff ff       	call   80103f12 <myproc>
8010669b:	85 c0                	test   %eax,%eax
8010669d:	74 1d                	je     801066bc <trap+0x2a6>
8010669f:	e8 6e d8 ff ff       	call   80103f12 <myproc>
801066a4:	8b 40 0c             	mov    0xc(%eax),%eax
801066a7:	83 f8 04             	cmp    $0x4,%eax
801066aa:	75 10                	jne    801066bc <trap+0x2a6>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801066ac:	8b 45 08             	mov    0x8(%ebp),%eax
801066af:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801066b2:	83 f8 20             	cmp    $0x20,%eax
801066b5:	75 05                	jne    801066bc <trap+0x2a6>
    yield();
801066b7:	e8 7f e0 ff ff       	call   8010473b <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801066bc:	e8 51 d8 ff ff       	call   80103f12 <myproc>
801066c1:	85 c0                	test   %eax,%eax
801066c3:	74 26                	je     801066eb <trap+0x2d5>
801066c5:	e8 48 d8 ff ff       	call   80103f12 <myproc>
801066ca:	8b 40 24             	mov    0x24(%eax),%eax
801066cd:	85 c0                	test   %eax,%eax
801066cf:	74 1a                	je     801066eb <trap+0x2d5>
801066d1:	8b 45 08             	mov    0x8(%ebp),%eax
801066d4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801066d8:	0f b7 c0             	movzwl %ax,%eax
801066db:	83 e0 03             	and    $0x3,%eax
801066de:	83 f8 03             	cmp    $0x3,%eax
801066e1:	75 08                	jne    801066eb <trap+0x2d5>
    exit();
801066e3:	e8 a2 dc ff ff       	call   8010438a <exit>
801066e8:	eb 01                	jmp    801066eb <trap+0x2d5>
    return;
801066ea:	90                   	nop
}
801066eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066ee:	5b                   	pop    %ebx
801066ef:	5e                   	pop    %esi
801066f0:	5f                   	pop    %edi
801066f1:	5d                   	pop    %ebp
801066f2:	c3                   	ret

801066f3 <inb>:
{
801066f3:	55                   	push   %ebp
801066f4:	89 e5                	mov    %esp,%ebp
801066f6:	83 ec 14             	sub    $0x14,%esp
801066f9:	8b 45 08             	mov    0x8(%ebp),%eax
801066fc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106700:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106704:	89 c2                	mov    %eax,%edx
80106706:	ec                   	in     (%dx),%al
80106707:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010670a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010670e:	c9                   	leave
8010670f:	c3                   	ret

80106710 <outb>:
{
80106710:	55                   	push   %ebp
80106711:	89 e5                	mov    %esp,%ebp
80106713:	83 ec 08             	sub    $0x8,%esp
80106716:	8b 55 08             	mov    0x8(%ebp),%edx
80106719:	8b 45 0c             	mov    0xc(%ebp),%eax
8010671c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106720:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106723:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106727:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010672b:	ee                   	out    %al,(%dx)
}
8010672c:	90                   	nop
8010672d:	c9                   	leave
8010672e:	c3                   	ret

8010672f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010672f:	55                   	push   %ebp
80106730:	89 e5                	mov    %esp,%ebp
80106732:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106735:	6a 00                	push   $0x0
80106737:	68 fa 03 00 00       	push   $0x3fa
8010673c:	e8 cf ff ff ff       	call   80106710 <outb>
80106741:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106744:	68 80 00 00 00       	push   $0x80
80106749:	68 fb 03 00 00       	push   $0x3fb
8010674e:	e8 bd ff ff ff       	call   80106710 <outb>
80106753:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106756:	6a 0c                	push   $0xc
80106758:	68 f8 03 00 00       	push   $0x3f8
8010675d:	e8 ae ff ff ff       	call   80106710 <outb>
80106762:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106765:	6a 00                	push   $0x0
80106767:	68 f9 03 00 00       	push   $0x3f9
8010676c:	e8 9f ff ff ff       	call   80106710 <outb>
80106771:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106774:	6a 03                	push   $0x3
80106776:	68 fb 03 00 00       	push   $0x3fb
8010677b:	e8 90 ff ff ff       	call   80106710 <outb>
80106780:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106783:	6a 00                	push   $0x0
80106785:	68 fc 03 00 00       	push   $0x3fc
8010678a:	e8 81 ff ff ff       	call   80106710 <outb>
8010678f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106792:	6a 01                	push   $0x1
80106794:	68 f9 03 00 00       	push   $0x3f9
80106799:	e8 72 ff ff ff       	call   80106710 <outb>
8010679e:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801067a1:	68 fd 03 00 00       	push   $0x3fd
801067a6:	e8 48 ff ff ff       	call   801066f3 <inb>
801067ab:	83 c4 04             	add    $0x4,%esp
801067ae:	3c ff                	cmp    $0xff,%al
801067b0:	74 61                	je     80106813 <uartinit+0xe4>
    return;
  uart = 1;
801067b2:	c7 05 b8 9a 11 80 01 	movl   $0x1,0x80119ab8
801067b9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801067bc:	68 fa 03 00 00       	push   $0x3fa
801067c1:	e8 2d ff ff ff       	call   801066f3 <inb>
801067c6:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801067c9:	68 f8 03 00 00       	push   $0x3f8
801067ce:	e8 20 ff ff ff       	call   801066f3 <inb>
801067d3:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801067d6:	83 ec 08             	sub    $0x8,%esp
801067d9:	6a 00                	push   $0x0
801067db:	6a 04                	push   $0x4
801067dd:	e8 36 c3 ff ff       	call   80102b18 <ioapicenable>
801067e2:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801067e5:	c7 45 f4 30 aa 10 80 	movl   $0x8010aa30,-0xc(%ebp)
801067ec:	eb 19                	jmp    80106807 <uartinit+0xd8>
    uartputc(*p);
801067ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f1:	0f b6 00             	movzbl (%eax),%eax
801067f4:	0f be c0             	movsbl %al,%eax
801067f7:	83 ec 0c             	sub    $0xc,%esp
801067fa:	50                   	push   %eax
801067fb:	e8 16 00 00 00       	call   80106816 <uartputc>
80106800:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106803:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680a:	0f b6 00             	movzbl (%eax),%eax
8010680d:	84 c0                	test   %al,%al
8010680f:	75 dd                	jne    801067ee <uartinit+0xbf>
80106811:	eb 01                	jmp    80106814 <uartinit+0xe5>
    return;
80106813:	90                   	nop
}
80106814:	c9                   	leave
80106815:	c3                   	ret

80106816 <uartputc>:

void
uartputc(int c)
{
80106816:	55                   	push   %ebp
80106817:	89 e5                	mov    %esp,%ebp
80106819:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010681c:	a1 b8 9a 11 80       	mov    0x80119ab8,%eax
80106821:	85 c0                	test   %eax,%eax
80106823:	74 53                	je     80106878 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106825:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010682c:	eb 11                	jmp    8010683f <uartputc+0x29>
    microdelay(10);
8010682e:	83 ec 0c             	sub    $0xc,%esp
80106831:	6a 0a                	push   $0xa
80106833:	e8 e3 c7 ff ff       	call   8010301b <microdelay>
80106838:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010683b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010683f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106843:	7f 1a                	jg     8010685f <uartputc+0x49>
80106845:	83 ec 0c             	sub    $0xc,%esp
80106848:	68 fd 03 00 00       	push   $0x3fd
8010684d:	e8 a1 fe ff ff       	call   801066f3 <inb>
80106852:	83 c4 10             	add    $0x10,%esp
80106855:	0f b6 c0             	movzbl %al,%eax
80106858:	83 e0 20             	and    $0x20,%eax
8010685b:	85 c0                	test   %eax,%eax
8010685d:	74 cf                	je     8010682e <uartputc+0x18>
  outb(COM1+0, c);
8010685f:	8b 45 08             	mov    0x8(%ebp),%eax
80106862:	0f b6 c0             	movzbl %al,%eax
80106865:	83 ec 08             	sub    $0x8,%esp
80106868:	50                   	push   %eax
80106869:	68 f8 03 00 00       	push   $0x3f8
8010686e:	e8 9d fe ff ff       	call   80106710 <outb>
80106873:	83 c4 10             	add    $0x10,%esp
80106876:	eb 01                	jmp    80106879 <uartputc+0x63>
    return;
80106878:	90                   	nop
}
80106879:	c9                   	leave
8010687a:	c3                   	ret

8010687b <uartgetc>:

static int
uartgetc(void)
{
8010687b:	55                   	push   %ebp
8010687c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010687e:	a1 b8 9a 11 80       	mov    0x80119ab8,%eax
80106883:	85 c0                	test   %eax,%eax
80106885:	75 07                	jne    8010688e <uartgetc+0x13>
    return -1;
80106887:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010688c:	eb 2e                	jmp    801068bc <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010688e:	68 fd 03 00 00       	push   $0x3fd
80106893:	e8 5b fe ff ff       	call   801066f3 <inb>
80106898:	83 c4 04             	add    $0x4,%esp
8010689b:	0f b6 c0             	movzbl %al,%eax
8010689e:	83 e0 01             	and    $0x1,%eax
801068a1:	85 c0                	test   %eax,%eax
801068a3:	75 07                	jne    801068ac <uartgetc+0x31>
    return -1;
801068a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068aa:	eb 10                	jmp    801068bc <uartgetc+0x41>
  return inb(COM1+0);
801068ac:	68 f8 03 00 00       	push   $0x3f8
801068b1:	e8 3d fe ff ff       	call   801066f3 <inb>
801068b6:	83 c4 04             	add    $0x4,%esp
801068b9:	0f b6 c0             	movzbl %al,%eax
}
801068bc:	c9                   	leave
801068bd:	c3                   	ret

801068be <uartintr>:

void
uartintr(void)
{
801068be:	55                   	push   %ebp
801068bf:	89 e5                	mov    %esp,%ebp
801068c1:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801068c4:	83 ec 0c             	sub    $0xc,%esp
801068c7:	68 7b 68 10 80       	push   $0x8010687b
801068cc:	e8 05 9f ff ff       	call   801007d6 <consoleintr>
801068d1:	83 c4 10             	add    $0x10,%esp
}
801068d4:	90                   	nop
801068d5:	c9                   	leave
801068d6:	c3                   	ret

801068d7 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801068d7:	6a 00                	push   $0x0
  pushl $0
801068d9:	6a 00                	push   $0x0
  jmp alltraps
801068db:	e9 4a f9 ff ff       	jmp    8010622a <alltraps>

801068e0 <vector1>:
.globl vector1
vector1:
  pushl $0
801068e0:	6a 00                	push   $0x0
  pushl $1
801068e2:	6a 01                	push   $0x1
  jmp alltraps
801068e4:	e9 41 f9 ff ff       	jmp    8010622a <alltraps>

801068e9 <vector2>:
.globl vector2
vector2:
  pushl $0
801068e9:	6a 00                	push   $0x0
  pushl $2
801068eb:	6a 02                	push   $0x2
  jmp alltraps
801068ed:	e9 38 f9 ff ff       	jmp    8010622a <alltraps>

801068f2 <vector3>:
.globl vector3
vector3:
  pushl $0
801068f2:	6a 00                	push   $0x0
  pushl $3
801068f4:	6a 03                	push   $0x3
  jmp alltraps
801068f6:	e9 2f f9 ff ff       	jmp    8010622a <alltraps>

801068fb <vector4>:
.globl vector4
vector4:
  pushl $0
801068fb:	6a 00                	push   $0x0
  pushl $4
801068fd:	6a 04                	push   $0x4
  jmp alltraps
801068ff:	e9 26 f9 ff ff       	jmp    8010622a <alltraps>

80106904 <vector5>:
.globl vector5
vector5:
  pushl $0
80106904:	6a 00                	push   $0x0
  pushl $5
80106906:	6a 05                	push   $0x5
  jmp alltraps
80106908:	e9 1d f9 ff ff       	jmp    8010622a <alltraps>

8010690d <vector6>:
.globl vector6
vector6:
  pushl $0
8010690d:	6a 00                	push   $0x0
  pushl $6
8010690f:	6a 06                	push   $0x6
  jmp alltraps
80106911:	e9 14 f9 ff ff       	jmp    8010622a <alltraps>

80106916 <vector7>:
.globl vector7
vector7:
  pushl $0
80106916:	6a 00                	push   $0x0
  pushl $7
80106918:	6a 07                	push   $0x7
  jmp alltraps
8010691a:	e9 0b f9 ff ff       	jmp    8010622a <alltraps>

8010691f <vector8>:
.globl vector8
vector8:
  pushl $8
8010691f:	6a 08                	push   $0x8
  jmp alltraps
80106921:	e9 04 f9 ff ff       	jmp    8010622a <alltraps>

80106926 <vector9>:
.globl vector9
vector9:
  pushl $0
80106926:	6a 00                	push   $0x0
  pushl $9
80106928:	6a 09                	push   $0x9
  jmp alltraps
8010692a:	e9 fb f8 ff ff       	jmp    8010622a <alltraps>

8010692f <vector10>:
.globl vector10
vector10:
  pushl $10
8010692f:	6a 0a                	push   $0xa
  jmp alltraps
80106931:	e9 f4 f8 ff ff       	jmp    8010622a <alltraps>

80106936 <vector11>:
.globl vector11
vector11:
  pushl $11
80106936:	6a 0b                	push   $0xb
  jmp alltraps
80106938:	e9 ed f8 ff ff       	jmp    8010622a <alltraps>

8010693d <vector12>:
.globl vector12
vector12:
  pushl $12
8010693d:	6a 0c                	push   $0xc
  jmp alltraps
8010693f:	e9 e6 f8 ff ff       	jmp    8010622a <alltraps>

80106944 <vector13>:
.globl vector13
vector13:
  pushl $13
80106944:	6a 0d                	push   $0xd
  jmp alltraps
80106946:	e9 df f8 ff ff       	jmp    8010622a <alltraps>

8010694b <vector14>:
.globl vector14
vector14:
  pushl $14
8010694b:	6a 0e                	push   $0xe
  jmp alltraps
8010694d:	e9 d8 f8 ff ff       	jmp    8010622a <alltraps>

80106952 <vector15>:
.globl vector15
vector15:
  pushl $0
80106952:	6a 00                	push   $0x0
  pushl $15
80106954:	6a 0f                	push   $0xf
  jmp alltraps
80106956:	e9 cf f8 ff ff       	jmp    8010622a <alltraps>

8010695b <vector16>:
.globl vector16
vector16:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $16
8010695d:	6a 10                	push   $0x10
  jmp alltraps
8010695f:	e9 c6 f8 ff ff       	jmp    8010622a <alltraps>

80106964 <vector17>:
.globl vector17
vector17:
  pushl $17
80106964:	6a 11                	push   $0x11
  jmp alltraps
80106966:	e9 bf f8 ff ff       	jmp    8010622a <alltraps>

8010696b <vector18>:
.globl vector18
vector18:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $18
8010696d:	6a 12                	push   $0x12
  jmp alltraps
8010696f:	e9 b6 f8 ff ff       	jmp    8010622a <alltraps>

80106974 <vector19>:
.globl vector19
vector19:
  pushl $0
80106974:	6a 00                	push   $0x0
  pushl $19
80106976:	6a 13                	push   $0x13
  jmp alltraps
80106978:	e9 ad f8 ff ff       	jmp    8010622a <alltraps>

8010697d <vector20>:
.globl vector20
vector20:
  pushl $0
8010697d:	6a 00                	push   $0x0
  pushl $20
8010697f:	6a 14                	push   $0x14
  jmp alltraps
80106981:	e9 a4 f8 ff ff       	jmp    8010622a <alltraps>

80106986 <vector21>:
.globl vector21
vector21:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $21
80106988:	6a 15                	push   $0x15
  jmp alltraps
8010698a:	e9 9b f8 ff ff       	jmp    8010622a <alltraps>

8010698f <vector22>:
.globl vector22
vector22:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $22
80106991:	6a 16                	push   $0x16
  jmp alltraps
80106993:	e9 92 f8 ff ff       	jmp    8010622a <alltraps>

80106998 <vector23>:
.globl vector23
vector23:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $23
8010699a:	6a 17                	push   $0x17
  jmp alltraps
8010699c:	e9 89 f8 ff ff       	jmp    8010622a <alltraps>

801069a1 <vector24>:
.globl vector24
vector24:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $24
801069a3:	6a 18                	push   $0x18
  jmp alltraps
801069a5:	e9 80 f8 ff ff       	jmp    8010622a <alltraps>

801069aa <vector25>:
.globl vector25
vector25:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $25
801069ac:	6a 19                	push   $0x19
  jmp alltraps
801069ae:	e9 77 f8 ff ff       	jmp    8010622a <alltraps>

801069b3 <vector26>:
.globl vector26
vector26:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $26
801069b5:	6a 1a                	push   $0x1a
  jmp alltraps
801069b7:	e9 6e f8 ff ff       	jmp    8010622a <alltraps>

801069bc <vector27>:
.globl vector27
vector27:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $27
801069be:	6a 1b                	push   $0x1b
  jmp alltraps
801069c0:	e9 65 f8 ff ff       	jmp    8010622a <alltraps>

801069c5 <vector28>:
.globl vector28
vector28:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $28
801069c7:	6a 1c                	push   $0x1c
  jmp alltraps
801069c9:	e9 5c f8 ff ff       	jmp    8010622a <alltraps>

801069ce <vector29>:
.globl vector29
vector29:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $29
801069d0:	6a 1d                	push   $0x1d
  jmp alltraps
801069d2:	e9 53 f8 ff ff       	jmp    8010622a <alltraps>

801069d7 <vector30>:
.globl vector30
vector30:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $30
801069d9:	6a 1e                	push   $0x1e
  jmp alltraps
801069db:	e9 4a f8 ff ff       	jmp    8010622a <alltraps>

801069e0 <vector31>:
.globl vector31
vector31:
  pushl $0
801069e0:	6a 00                	push   $0x0
  pushl $31
801069e2:	6a 1f                	push   $0x1f
  jmp alltraps
801069e4:	e9 41 f8 ff ff       	jmp    8010622a <alltraps>

801069e9 <vector32>:
.globl vector32
vector32:
  pushl $0
801069e9:	6a 00                	push   $0x0
  pushl $32
801069eb:	6a 20                	push   $0x20
  jmp alltraps
801069ed:	e9 38 f8 ff ff       	jmp    8010622a <alltraps>

801069f2 <vector33>:
.globl vector33
vector33:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $33
801069f4:	6a 21                	push   $0x21
  jmp alltraps
801069f6:	e9 2f f8 ff ff       	jmp    8010622a <alltraps>

801069fb <vector34>:
.globl vector34
vector34:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $34
801069fd:	6a 22                	push   $0x22
  jmp alltraps
801069ff:	e9 26 f8 ff ff       	jmp    8010622a <alltraps>

80106a04 <vector35>:
.globl vector35
vector35:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $35
80106a06:	6a 23                	push   $0x23
  jmp alltraps
80106a08:	e9 1d f8 ff ff       	jmp    8010622a <alltraps>

80106a0d <vector36>:
.globl vector36
vector36:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $36
80106a0f:	6a 24                	push   $0x24
  jmp alltraps
80106a11:	e9 14 f8 ff ff       	jmp    8010622a <alltraps>

80106a16 <vector37>:
.globl vector37
vector37:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $37
80106a18:	6a 25                	push   $0x25
  jmp alltraps
80106a1a:	e9 0b f8 ff ff       	jmp    8010622a <alltraps>

80106a1f <vector38>:
.globl vector38
vector38:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $38
80106a21:	6a 26                	push   $0x26
  jmp alltraps
80106a23:	e9 02 f8 ff ff       	jmp    8010622a <alltraps>

80106a28 <vector39>:
.globl vector39
vector39:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $39
80106a2a:	6a 27                	push   $0x27
  jmp alltraps
80106a2c:	e9 f9 f7 ff ff       	jmp    8010622a <alltraps>

80106a31 <vector40>:
.globl vector40
vector40:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $40
80106a33:	6a 28                	push   $0x28
  jmp alltraps
80106a35:	e9 f0 f7 ff ff       	jmp    8010622a <alltraps>

80106a3a <vector41>:
.globl vector41
vector41:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $41
80106a3c:	6a 29                	push   $0x29
  jmp alltraps
80106a3e:	e9 e7 f7 ff ff       	jmp    8010622a <alltraps>

80106a43 <vector42>:
.globl vector42
vector42:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $42
80106a45:	6a 2a                	push   $0x2a
  jmp alltraps
80106a47:	e9 de f7 ff ff       	jmp    8010622a <alltraps>

80106a4c <vector43>:
.globl vector43
vector43:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $43
80106a4e:	6a 2b                	push   $0x2b
  jmp alltraps
80106a50:	e9 d5 f7 ff ff       	jmp    8010622a <alltraps>

80106a55 <vector44>:
.globl vector44
vector44:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $44
80106a57:	6a 2c                	push   $0x2c
  jmp alltraps
80106a59:	e9 cc f7 ff ff       	jmp    8010622a <alltraps>

80106a5e <vector45>:
.globl vector45
vector45:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $45
80106a60:	6a 2d                	push   $0x2d
  jmp alltraps
80106a62:	e9 c3 f7 ff ff       	jmp    8010622a <alltraps>

80106a67 <vector46>:
.globl vector46
vector46:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $46
80106a69:	6a 2e                	push   $0x2e
  jmp alltraps
80106a6b:	e9 ba f7 ff ff       	jmp    8010622a <alltraps>

80106a70 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $47
80106a72:	6a 2f                	push   $0x2f
  jmp alltraps
80106a74:	e9 b1 f7 ff ff       	jmp    8010622a <alltraps>

80106a79 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $48
80106a7b:	6a 30                	push   $0x30
  jmp alltraps
80106a7d:	e9 a8 f7 ff ff       	jmp    8010622a <alltraps>

80106a82 <vector49>:
.globl vector49
vector49:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $49
80106a84:	6a 31                	push   $0x31
  jmp alltraps
80106a86:	e9 9f f7 ff ff       	jmp    8010622a <alltraps>

80106a8b <vector50>:
.globl vector50
vector50:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $50
80106a8d:	6a 32                	push   $0x32
  jmp alltraps
80106a8f:	e9 96 f7 ff ff       	jmp    8010622a <alltraps>

80106a94 <vector51>:
.globl vector51
vector51:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $51
80106a96:	6a 33                	push   $0x33
  jmp alltraps
80106a98:	e9 8d f7 ff ff       	jmp    8010622a <alltraps>

80106a9d <vector52>:
.globl vector52
vector52:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $52
80106a9f:	6a 34                	push   $0x34
  jmp alltraps
80106aa1:	e9 84 f7 ff ff       	jmp    8010622a <alltraps>

80106aa6 <vector53>:
.globl vector53
vector53:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $53
80106aa8:	6a 35                	push   $0x35
  jmp alltraps
80106aaa:	e9 7b f7 ff ff       	jmp    8010622a <alltraps>

80106aaf <vector54>:
.globl vector54
vector54:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $54
80106ab1:	6a 36                	push   $0x36
  jmp alltraps
80106ab3:	e9 72 f7 ff ff       	jmp    8010622a <alltraps>

80106ab8 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ab8:	6a 00                	push   $0x0
  pushl $55
80106aba:	6a 37                	push   $0x37
  jmp alltraps
80106abc:	e9 69 f7 ff ff       	jmp    8010622a <alltraps>

80106ac1 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ac1:	6a 00                	push   $0x0
  pushl $56
80106ac3:	6a 38                	push   $0x38
  jmp alltraps
80106ac5:	e9 60 f7 ff ff       	jmp    8010622a <alltraps>

80106aca <vector57>:
.globl vector57
vector57:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $57
80106acc:	6a 39                	push   $0x39
  jmp alltraps
80106ace:	e9 57 f7 ff ff       	jmp    8010622a <alltraps>

80106ad3 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $58
80106ad5:	6a 3a                	push   $0x3a
  jmp alltraps
80106ad7:	e9 4e f7 ff ff       	jmp    8010622a <alltraps>

80106adc <vector59>:
.globl vector59
vector59:
  pushl $0
80106adc:	6a 00                	push   $0x0
  pushl $59
80106ade:	6a 3b                	push   $0x3b
  jmp alltraps
80106ae0:	e9 45 f7 ff ff       	jmp    8010622a <alltraps>

80106ae5 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ae5:	6a 00                	push   $0x0
  pushl $60
80106ae7:	6a 3c                	push   $0x3c
  jmp alltraps
80106ae9:	e9 3c f7 ff ff       	jmp    8010622a <alltraps>

80106aee <vector61>:
.globl vector61
vector61:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $61
80106af0:	6a 3d                	push   $0x3d
  jmp alltraps
80106af2:	e9 33 f7 ff ff       	jmp    8010622a <alltraps>

80106af7 <vector62>:
.globl vector62
vector62:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $62
80106af9:	6a 3e                	push   $0x3e
  jmp alltraps
80106afb:	e9 2a f7 ff ff       	jmp    8010622a <alltraps>

80106b00 <vector63>:
.globl vector63
vector63:
  pushl $0
80106b00:	6a 00                	push   $0x0
  pushl $63
80106b02:	6a 3f                	push   $0x3f
  jmp alltraps
80106b04:	e9 21 f7 ff ff       	jmp    8010622a <alltraps>

80106b09 <vector64>:
.globl vector64
vector64:
  pushl $0
80106b09:	6a 00                	push   $0x0
  pushl $64
80106b0b:	6a 40                	push   $0x40
  jmp alltraps
80106b0d:	e9 18 f7 ff ff       	jmp    8010622a <alltraps>

80106b12 <vector65>:
.globl vector65
vector65:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $65
80106b14:	6a 41                	push   $0x41
  jmp alltraps
80106b16:	e9 0f f7 ff ff       	jmp    8010622a <alltraps>

80106b1b <vector66>:
.globl vector66
vector66:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $66
80106b1d:	6a 42                	push   $0x42
  jmp alltraps
80106b1f:	e9 06 f7 ff ff       	jmp    8010622a <alltraps>

80106b24 <vector67>:
.globl vector67
vector67:
  pushl $0
80106b24:	6a 00                	push   $0x0
  pushl $67
80106b26:	6a 43                	push   $0x43
  jmp alltraps
80106b28:	e9 fd f6 ff ff       	jmp    8010622a <alltraps>

80106b2d <vector68>:
.globl vector68
vector68:
  pushl $0
80106b2d:	6a 00                	push   $0x0
  pushl $68
80106b2f:	6a 44                	push   $0x44
  jmp alltraps
80106b31:	e9 f4 f6 ff ff       	jmp    8010622a <alltraps>

80106b36 <vector69>:
.globl vector69
vector69:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $69
80106b38:	6a 45                	push   $0x45
  jmp alltraps
80106b3a:	e9 eb f6 ff ff       	jmp    8010622a <alltraps>

80106b3f <vector70>:
.globl vector70
vector70:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $70
80106b41:	6a 46                	push   $0x46
  jmp alltraps
80106b43:	e9 e2 f6 ff ff       	jmp    8010622a <alltraps>

80106b48 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $71
80106b4a:	6a 47                	push   $0x47
  jmp alltraps
80106b4c:	e9 d9 f6 ff ff       	jmp    8010622a <alltraps>

80106b51 <vector72>:
.globl vector72
vector72:
  pushl $0
80106b51:	6a 00                	push   $0x0
  pushl $72
80106b53:	6a 48                	push   $0x48
  jmp alltraps
80106b55:	e9 d0 f6 ff ff       	jmp    8010622a <alltraps>

80106b5a <vector73>:
.globl vector73
vector73:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $73
80106b5c:	6a 49                	push   $0x49
  jmp alltraps
80106b5e:	e9 c7 f6 ff ff       	jmp    8010622a <alltraps>

80106b63 <vector74>:
.globl vector74
vector74:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $74
80106b65:	6a 4a                	push   $0x4a
  jmp alltraps
80106b67:	e9 be f6 ff ff       	jmp    8010622a <alltraps>

80106b6c <vector75>:
.globl vector75
vector75:
  pushl $0
80106b6c:	6a 00                	push   $0x0
  pushl $75
80106b6e:	6a 4b                	push   $0x4b
  jmp alltraps
80106b70:	e9 b5 f6 ff ff       	jmp    8010622a <alltraps>

80106b75 <vector76>:
.globl vector76
vector76:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $76
80106b77:	6a 4c                	push   $0x4c
  jmp alltraps
80106b79:	e9 ac f6 ff ff       	jmp    8010622a <alltraps>

80106b7e <vector77>:
.globl vector77
vector77:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $77
80106b80:	6a 4d                	push   $0x4d
  jmp alltraps
80106b82:	e9 a3 f6 ff ff       	jmp    8010622a <alltraps>

80106b87 <vector78>:
.globl vector78
vector78:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $78
80106b89:	6a 4e                	push   $0x4e
  jmp alltraps
80106b8b:	e9 9a f6 ff ff       	jmp    8010622a <alltraps>

80106b90 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $79
80106b92:	6a 4f                	push   $0x4f
  jmp alltraps
80106b94:	e9 91 f6 ff ff       	jmp    8010622a <alltraps>

80106b99 <vector80>:
.globl vector80
vector80:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $80
80106b9b:	6a 50                	push   $0x50
  jmp alltraps
80106b9d:	e9 88 f6 ff ff       	jmp    8010622a <alltraps>

80106ba2 <vector81>:
.globl vector81
vector81:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $81
80106ba4:	6a 51                	push   $0x51
  jmp alltraps
80106ba6:	e9 7f f6 ff ff       	jmp    8010622a <alltraps>

80106bab <vector82>:
.globl vector82
vector82:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $82
80106bad:	6a 52                	push   $0x52
  jmp alltraps
80106baf:	e9 76 f6 ff ff       	jmp    8010622a <alltraps>

80106bb4 <vector83>:
.globl vector83
vector83:
  pushl $0
80106bb4:	6a 00                	push   $0x0
  pushl $83
80106bb6:	6a 53                	push   $0x53
  jmp alltraps
80106bb8:	e9 6d f6 ff ff       	jmp    8010622a <alltraps>

80106bbd <vector84>:
.globl vector84
vector84:
  pushl $0
80106bbd:	6a 00                	push   $0x0
  pushl $84
80106bbf:	6a 54                	push   $0x54
  jmp alltraps
80106bc1:	e9 64 f6 ff ff       	jmp    8010622a <alltraps>

80106bc6 <vector85>:
.globl vector85
vector85:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $85
80106bc8:	6a 55                	push   $0x55
  jmp alltraps
80106bca:	e9 5b f6 ff ff       	jmp    8010622a <alltraps>

80106bcf <vector86>:
.globl vector86
vector86:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $86
80106bd1:	6a 56                	push   $0x56
  jmp alltraps
80106bd3:	e9 52 f6 ff ff       	jmp    8010622a <alltraps>

80106bd8 <vector87>:
.globl vector87
vector87:
  pushl $0
80106bd8:	6a 00                	push   $0x0
  pushl $87
80106bda:	6a 57                	push   $0x57
  jmp alltraps
80106bdc:	e9 49 f6 ff ff       	jmp    8010622a <alltraps>

80106be1 <vector88>:
.globl vector88
vector88:
  pushl $0
80106be1:	6a 00                	push   $0x0
  pushl $88
80106be3:	6a 58                	push   $0x58
  jmp alltraps
80106be5:	e9 40 f6 ff ff       	jmp    8010622a <alltraps>

80106bea <vector89>:
.globl vector89
vector89:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $89
80106bec:	6a 59                	push   $0x59
  jmp alltraps
80106bee:	e9 37 f6 ff ff       	jmp    8010622a <alltraps>

80106bf3 <vector90>:
.globl vector90
vector90:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $90
80106bf5:	6a 5a                	push   $0x5a
  jmp alltraps
80106bf7:	e9 2e f6 ff ff       	jmp    8010622a <alltraps>

80106bfc <vector91>:
.globl vector91
vector91:
  pushl $0
80106bfc:	6a 00                	push   $0x0
  pushl $91
80106bfe:	6a 5b                	push   $0x5b
  jmp alltraps
80106c00:	e9 25 f6 ff ff       	jmp    8010622a <alltraps>

80106c05 <vector92>:
.globl vector92
vector92:
  pushl $0
80106c05:	6a 00                	push   $0x0
  pushl $92
80106c07:	6a 5c                	push   $0x5c
  jmp alltraps
80106c09:	e9 1c f6 ff ff       	jmp    8010622a <alltraps>

80106c0e <vector93>:
.globl vector93
vector93:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $93
80106c10:	6a 5d                	push   $0x5d
  jmp alltraps
80106c12:	e9 13 f6 ff ff       	jmp    8010622a <alltraps>

80106c17 <vector94>:
.globl vector94
vector94:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $94
80106c19:	6a 5e                	push   $0x5e
  jmp alltraps
80106c1b:	e9 0a f6 ff ff       	jmp    8010622a <alltraps>

80106c20 <vector95>:
.globl vector95
vector95:
  pushl $0
80106c20:	6a 00                	push   $0x0
  pushl $95
80106c22:	6a 5f                	push   $0x5f
  jmp alltraps
80106c24:	e9 01 f6 ff ff       	jmp    8010622a <alltraps>

80106c29 <vector96>:
.globl vector96
vector96:
  pushl $0
80106c29:	6a 00                	push   $0x0
  pushl $96
80106c2b:	6a 60                	push   $0x60
  jmp alltraps
80106c2d:	e9 f8 f5 ff ff       	jmp    8010622a <alltraps>

80106c32 <vector97>:
.globl vector97
vector97:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $97
80106c34:	6a 61                	push   $0x61
  jmp alltraps
80106c36:	e9 ef f5 ff ff       	jmp    8010622a <alltraps>

80106c3b <vector98>:
.globl vector98
vector98:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $98
80106c3d:	6a 62                	push   $0x62
  jmp alltraps
80106c3f:	e9 e6 f5 ff ff       	jmp    8010622a <alltraps>

80106c44 <vector99>:
.globl vector99
vector99:
  pushl $0
80106c44:	6a 00                	push   $0x0
  pushl $99
80106c46:	6a 63                	push   $0x63
  jmp alltraps
80106c48:	e9 dd f5 ff ff       	jmp    8010622a <alltraps>

80106c4d <vector100>:
.globl vector100
vector100:
  pushl $0
80106c4d:	6a 00                	push   $0x0
  pushl $100
80106c4f:	6a 64                	push   $0x64
  jmp alltraps
80106c51:	e9 d4 f5 ff ff       	jmp    8010622a <alltraps>

80106c56 <vector101>:
.globl vector101
vector101:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $101
80106c58:	6a 65                	push   $0x65
  jmp alltraps
80106c5a:	e9 cb f5 ff ff       	jmp    8010622a <alltraps>

80106c5f <vector102>:
.globl vector102
vector102:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $102
80106c61:	6a 66                	push   $0x66
  jmp alltraps
80106c63:	e9 c2 f5 ff ff       	jmp    8010622a <alltraps>

80106c68 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c68:	6a 00                	push   $0x0
  pushl $103
80106c6a:	6a 67                	push   $0x67
  jmp alltraps
80106c6c:	e9 b9 f5 ff ff       	jmp    8010622a <alltraps>

80106c71 <vector104>:
.globl vector104
vector104:
  pushl $0
80106c71:	6a 00                	push   $0x0
  pushl $104
80106c73:	6a 68                	push   $0x68
  jmp alltraps
80106c75:	e9 b0 f5 ff ff       	jmp    8010622a <alltraps>

80106c7a <vector105>:
.globl vector105
vector105:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $105
80106c7c:	6a 69                	push   $0x69
  jmp alltraps
80106c7e:	e9 a7 f5 ff ff       	jmp    8010622a <alltraps>

80106c83 <vector106>:
.globl vector106
vector106:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $106
80106c85:	6a 6a                	push   $0x6a
  jmp alltraps
80106c87:	e9 9e f5 ff ff       	jmp    8010622a <alltraps>

80106c8c <vector107>:
.globl vector107
vector107:
  pushl $0
80106c8c:	6a 00                	push   $0x0
  pushl $107
80106c8e:	6a 6b                	push   $0x6b
  jmp alltraps
80106c90:	e9 95 f5 ff ff       	jmp    8010622a <alltraps>

80106c95 <vector108>:
.globl vector108
vector108:
  pushl $0
80106c95:	6a 00                	push   $0x0
  pushl $108
80106c97:	6a 6c                	push   $0x6c
  jmp alltraps
80106c99:	e9 8c f5 ff ff       	jmp    8010622a <alltraps>

80106c9e <vector109>:
.globl vector109
vector109:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $109
80106ca0:	6a 6d                	push   $0x6d
  jmp alltraps
80106ca2:	e9 83 f5 ff ff       	jmp    8010622a <alltraps>

80106ca7 <vector110>:
.globl vector110
vector110:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $110
80106ca9:	6a 6e                	push   $0x6e
  jmp alltraps
80106cab:	e9 7a f5 ff ff       	jmp    8010622a <alltraps>

80106cb0 <vector111>:
.globl vector111
vector111:
  pushl $0
80106cb0:	6a 00                	push   $0x0
  pushl $111
80106cb2:	6a 6f                	push   $0x6f
  jmp alltraps
80106cb4:	e9 71 f5 ff ff       	jmp    8010622a <alltraps>

80106cb9 <vector112>:
.globl vector112
vector112:
  pushl $0
80106cb9:	6a 00                	push   $0x0
  pushl $112
80106cbb:	6a 70                	push   $0x70
  jmp alltraps
80106cbd:	e9 68 f5 ff ff       	jmp    8010622a <alltraps>

80106cc2 <vector113>:
.globl vector113
vector113:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $113
80106cc4:	6a 71                	push   $0x71
  jmp alltraps
80106cc6:	e9 5f f5 ff ff       	jmp    8010622a <alltraps>

80106ccb <vector114>:
.globl vector114
vector114:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $114
80106ccd:	6a 72                	push   $0x72
  jmp alltraps
80106ccf:	e9 56 f5 ff ff       	jmp    8010622a <alltraps>

80106cd4 <vector115>:
.globl vector115
vector115:
  pushl $0
80106cd4:	6a 00                	push   $0x0
  pushl $115
80106cd6:	6a 73                	push   $0x73
  jmp alltraps
80106cd8:	e9 4d f5 ff ff       	jmp    8010622a <alltraps>

80106cdd <vector116>:
.globl vector116
vector116:
  pushl $0
80106cdd:	6a 00                	push   $0x0
  pushl $116
80106cdf:	6a 74                	push   $0x74
  jmp alltraps
80106ce1:	e9 44 f5 ff ff       	jmp    8010622a <alltraps>

80106ce6 <vector117>:
.globl vector117
vector117:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $117
80106ce8:	6a 75                	push   $0x75
  jmp alltraps
80106cea:	e9 3b f5 ff ff       	jmp    8010622a <alltraps>

80106cef <vector118>:
.globl vector118
vector118:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $118
80106cf1:	6a 76                	push   $0x76
  jmp alltraps
80106cf3:	e9 32 f5 ff ff       	jmp    8010622a <alltraps>

80106cf8 <vector119>:
.globl vector119
vector119:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $119
80106cfa:	6a 77                	push   $0x77
  jmp alltraps
80106cfc:	e9 29 f5 ff ff       	jmp    8010622a <alltraps>

80106d01 <vector120>:
.globl vector120
vector120:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $120
80106d03:	6a 78                	push   $0x78
  jmp alltraps
80106d05:	e9 20 f5 ff ff       	jmp    8010622a <alltraps>

80106d0a <vector121>:
.globl vector121
vector121:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $121
80106d0c:	6a 79                	push   $0x79
  jmp alltraps
80106d0e:	e9 17 f5 ff ff       	jmp    8010622a <alltraps>

80106d13 <vector122>:
.globl vector122
vector122:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $122
80106d15:	6a 7a                	push   $0x7a
  jmp alltraps
80106d17:	e9 0e f5 ff ff       	jmp    8010622a <alltraps>

80106d1c <vector123>:
.globl vector123
vector123:
  pushl $0
80106d1c:	6a 00                	push   $0x0
  pushl $123
80106d1e:	6a 7b                	push   $0x7b
  jmp alltraps
80106d20:	e9 05 f5 ff ff       	jmp    8010622a <alltraps>

80106d25 <vector124>:
.globl vector124
vector124:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $124
80106d27:	6a 7c                	push   $0x7c
  jmp alltraps
80106d29:	e9 fc f4 ff ff       	jmp    8010622a <alltraps>

80106d2e <vector125>:
.globl vector125
vector125:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $125
80106d30:	6a 7d                	push   $0x7d
  jmp alltraps
80106d32:	e9 f3 f4 ff ff       	jmp    8010622a <alltraps>

80106d37 <vector126>:
.globl vector126
vector126:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $126
80106d39:	6a 7e                	push   $0x7e
  jmp alltraps
80106d3b:	e9 ea f4 ff ff       	jmp    8010622a <alltraps>

80106d40 <vector127>:
.globl vector127
vector127:
  pushl $0
80106d40:	6a 00                	push   $0x0
  pushl $127
80106d42:	6a 7f                	push   $0x7f
  jmp alltraps
80106d44:	e9 e1 f4 ff ff       	jmp    8010622a <alltraps>

80106d49 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d49:	6a 00                	push   $0x0
  pushl $128
80106d4b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d50:	e9 d5 f4 ff ff       	jmp    8010622a <alltraps>

80106d55 <vector129>:
.globl vector129
vector129:
  pushl $0
80106d55:	6a 00                	push   $0x0
  pushl $129
80106d57:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d5c:	e9 c9 f4 ff ff       	jmp    8010622a <alltraps>

80106d61 <vector130>:
.globl vector130
vector130:
  pushl $0
80106d61:	6a 00                	push   $0x0
  pushl $130
80106d63:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d68:	e9 bd f4 ff ff       	jmp    8010622a <alltraps>

80106d6d <vector131>:
.globl vector131
vector131:
  pushl $0
80106d6d:	6a 00                	push   $0x0
  pushl $131
80106d6f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d74:	e9 b1 f4 ff ff       	jmp    8010622a <alltraps>

80106d79 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d79:	6a 00                	push   $0x0
  pushl $132
80106d7b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d80:	e9 a5 f4 ff ff       	jmp    8010622a <alltraps>

80106d85 <vector133>:
.globl vector133
vector133:
  pushl $0
80106d85:	6a 00                	push   $0x0
  pushl $133
80106d87:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d8c:	e9 99 f4 ff ff       	jmp    8010622a <alltraps>

80106d91 <vector134>:
.globl vector134
vector134:
  pushl $0
80106d91:	6a 00                	push   $0x0
  pushl $134
80106d93:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106d98:	e9 8d f4 ff ff       	jmp    8010622a <alltraps>

80106d9d <vector135>:
.globl vector135
vector135:
  pushl $0
80106d9d:	6a 00                	push   $0x0
  pushl $135
80106d9f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106da4:	e9 81 f4 ff ff       	jmp    8010622a <alltraps>

80106da9 <vector136>:
.globl vector136
vector136:
  pushl $0
80106da9:	6a 00                	push   $0x0
  pushl $136
80106dab:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106db0:	e9 75 f4 ff ff       	jmp    8010622a <alltraps>

80106db5 <vector137>:
.globl vector137
vector137:
  pushl $0
80106db5:	6a 00                	push   $0x0
  pushl $137
80106db7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106dbc:	e9 69 f4 ff ff       	jmp    8010622a <alltraps>

80106dc1 <vector138>:
.globl vector138
vector138:
  pushl $0
80106dc1:	6a 00                	push   $0x0
  pushl $138
80106dc3:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106dc8:	e9 5d f4 ff ff       	jmp    8010622a <alltraps>

80106dcd <vector139>:
.globl vector139
vector139:
  pushl $0
80106dcd:	6a 00                	push   $0x0
  pushl $139
80106dcf:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106dd4:	e9 51 f4 ff ff       	jmp    8010622a <alltraps>

80106dd9 <vector140>:
.globl vector140
vector140:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $140
80106ddb:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106de0:	e9 45 f4 ff ff       	jmp    8010622a <alltraps>

80106de5 <vector141>:
.globl vector141
vector141:
  pushl $0
80106de5:	6a 00                	push   $0x0
  pushl $141
80106de7:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106dec:	e9 39 f4 ff ff       	jmp    8010622a <alltraps>

80106df1 <vector142>:
.globl vector142
vector142:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $142
80106df3:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106df8:	e9 2d f4 ff ff       	jmp    8010622a <alltraps>

80106dfd <vector143>:
.globl vector143
vector143:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $143
80106dff:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106e04:	e9 21 f4 ff ff       	jmp    8010622a <alltraps>

80106e09 <vector144>:
.globl vector144
vector144:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $144
80106e0b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106e10:	e9 15 f4 ff ff       	jmp    8010622a <alltraps>

80106e15 <vector145>:
.globl vector145
vector145:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $145
80106e17:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106e1c:	e9 09 f4 ff ff       	jmp    8010622a <alltraps>

80106e21 <vector146>:
.globl vector146
vector146:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $146
80106e23:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106e28:	e9 fd f3 ff ff       	jmp    8010622a <alltraps>

80106e2d <vector147>:
.globl vector147
vector147:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $147
80106e2f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e34:	e9 f1 f3 ff ff       	jmp    8010622a <alltraps>

80106e39 <vector148>:
.globl vector148
vector148:
  pushl $0
80106e39:	6a 00                	push   $0x0
  pushl $148
80106e3b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e40:	e9 e5 f3 ff ff       	jmp    8010622a <alltraps>

80106e45 <vector149>:
.globl vector149
vector149:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $149
80106e47:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e4c:	e9 d9 f3 ff ff       	jmp    8010622a <alltraps>

80106e51 <vector150>:
.globl vector150
vector150:
  pushl $0
80106e51:	6a 00                	push   $0x0
  pushl $150
80106e53:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e58:	e9 cd f3 ff ff       	jmp    8010622a <alltraps>

80106e5d <vector151>:
.globl vector151
vector151:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $151
80106e5f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e64:	e9 c1 f3 ff ff       	jmp    8010622a <alltraps>

80106e69 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e69:	6a 00                	push   $0x0
  pushl $152
80106e6b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e70:	e9 b5 f3 ff ff       	jmp    8010622a <alltraps>

80106e75 <vector153>:
.globl vector153
vector153:
  pushl $0
80106e75:	6a 00                	push   $0x0
  pushl $153
80106e77:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e7c:	e9 a9 f3 ff ff       	jmp    8010622a <alltraps>

80106e81 <vector154>:
.globl vector154
vector154:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $154
80106e83:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e88:	e9 9d f3 ff ff       	jmp    8010622a <alltraps>

80106e8d <vector155>:
.globl vector155
vector155:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $155
80106e8f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e94:	e9 91 f3 ff ff       	jmp    8010622a <alltraps>

80106e99 <vector156>:
.globl vector156
vector156:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $156
80106e9b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106ea0:	e9 85 f3 ff ff       	jmp    8010622a <alltraps>

80106ea5 <vector157>:
.globl vector157
vector157:
  pushl $0
80106ea5:	6a 00                	push   $0x0
  pushl $157
80106ea7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106eac:	e9 79 f3 ff ff       	jmp    8010622a <alltraps>

80106eb1 <vector158>:
.globl vector158
vector158:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $158
80106eb3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106eb8:	e9 6d f3 ff ff       	jmp    8010622a <alltraps>

80106ebd <vector159>:
.globl vector159
vector159:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $159
80106ebf:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ec4:	e9 61 f3 ff ff       	jmp    8010622a <alltraps>

80106ec9 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ec9:	6a 00                	push   $0x0
  pushl $160
80106ecb:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ed0:	e9 55 f3 ff ff       	jmp    8010622a <alltraps>

80106ed5 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $161
80106ed7:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106edc:	e9 49 f3 ff ff       	jmp    8010622a <alltraps>

80106ee1 <vector162>:
.globl vector162
vector162:
  pushl $0
80106ee1:	6a 00                	push   $0x0
  pushl $162
80106ee3:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ee8:	e9 3d f3 ff ff       	jmp    8010622a <alltraps>

80106eed <vector163>:
.globl vector163
vector163:
  pushl $0
80106eed:	6a 00                	push   $0x0
  pushl $163
80106eef:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ef4:	e9 31 f3 ff ff       	jmp    8010622a <alltraps>

80106ef9 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $164
80106efb:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106f00:	e9 25 f3 ff ff       	jmp    8010622a <alltraps>

80106f05 <vector165>:
.globl vector165
vector165:
  pushl $0
80106f05:	6a 00                	push   $0x0
  pushl $165
80106f07:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106f0c:	e9 19 f3 ff ff       	jmp    8010622a <alltraps>

80106f11 <vector166>:
.globl vector166
vector166:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $166
80106f13:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106f18:	e9 0d f3 ff ff       	jmp    8010622a <alltraps>

80106f1d <vector167>:
.globl vector167
vector167:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $167
80106f1f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106f24:	e9 01 f3 ff ff       	jmp    8010622a <alltraps>

80106f29 <vector168>:
.globl vector168
vector168:
  pushl $0
80106f29:	6a 00                	push   $0x0
  pushl $168
80106f2b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f30:	e9 f5 f2 ff ff       	jmp    8010622a <alltraps>

80106f35 <vector169>:
.globl vector169
vector169:
  pushl $0
80106f35:	6a 00                	push   $0x0
  pushl $169
80106f37:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f3c:	e9 e9 f2 ff ff       	jmp    8010622a <alltraps>

80106f41 <vector170>:
.globl vector170
vector170:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $170
80106f43:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f48:	e9 dd f2 ff ff       	jmp    8010622a <alltraps>

80106f4d <vector171>:
.globl vector171
vector171:
  pushl $0
80106f4d:	6a 00                	push   $0x0
  pushl $171
80106f4f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f54:	e9 d1 f2 ff ff       	jmp    8010622a <alltraps>

80106f59 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $172
80106f5b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f60:	e9 c5 f2 ff ff       	jmp    8010622a <alltraps>

80106f65 <vector173>:
.globl vector173
vector173:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $173
80106f67:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f6c:	e9 b9 f2 ff ff       	jmp    8010622a <alltraps>

80106f71 <vector174>:
.globl vector174
vector174:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $174
80106f73:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f78:	e9 ad f2 ff ff       	jmp    8010622a <alltraps>

80106f7d <vector175>:
.globl vector175
vector175:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $175
80106f7f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f84:	e9 a1 f2 ff ff       	jmp    8010622a <alltraps>

80106f89 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $176
80106f8b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f90:	e9 95 f2 ff ff       	jmp    8010622a <alltraps>

80106f95 <vector177>:
.globl vector177
vector177:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $177
80106f97:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106f9c:	e9 89 f2 ff ff       	jmp    8010622a <alltraps>

80106fa1 <vector178>:
.globl vector178
vector178:
  pushl $0
80106fa1:	6a 00                	push   $0x0
  pushl $178
80106fa3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106fa8:	e9 7d f2 ff ff       	jmp    8010622a <alltraps>

80106fad <vector179>:
.globl vector179
vector179:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $179
80106faf:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106fb4:	e9 71 f2 ff ff       	jmp    8010622a <alltraps>

80106fb9 <vector180>:
.globl vector180
vector180:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $180
80106fbb:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106fc0:	e9 65 f2 ff ff       	jmp    8010622a <alltraps>

80106fc5 <vector181>:
.globl vector181
vector181:
  pushl $0
80106fc5:	6a 00                	push   $0x0
  pushl $181
80106fc7:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106fcc:	e9 59 f2 ff ff       	jmp    8010622a <alltraps>

80106fd1 <vector182>:
.globl vector182
vector182:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $182
80106fd3:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106fd8:	e9 4d f2 ff ff       	jmp    8010622a <alltraps>

80106fdd <vector183>:
.globl vector183
vector183:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $183
80106fdf:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106fe4:	e9 41 f2 ff ff       	jmp    8010622a <alltraps>

80106fe9 <vector184>:
.globl vector184
vector184:
  pushl $0
80106fe9:	6a 00                	push   $0x0
  pushl $184
80106feb:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ff0:	e9 35 f2 ff ff       	jmp    8010622a <alltraps>

80106ff5 <vector185>:
.globl vector185
vector185:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $185
80106ff7:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106ffc:	e9 29 f2 ff ff       	jmp    8010622a <alltraps>

80107001 <vector186>:
.globl vector186
vector186:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $186
80107003:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107008:	e9 1d f2 ff ff       	jmp    8010622a <alltraps>

8010700d <vector187>:
.globl vector187
vector187:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $187
8010700f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107014:	e9 11 f2 ff ff       	jmp    8010622a <alltraps>

80107019 <vector188>:
.globl vector188
vector188:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $188
8010701b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107020:	e9 05 f2 ff ff       	jmp    8010622a <alltraps>

80107025 <vector189>:
.globl vector189
vector189:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $189
80107027:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010702c:	e9 f9 f1 ff ff       	jmp    8010622a <alltraps>

80107031 <vector190>:
.globl vector190
vector190:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $190
80107033:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107038:	e9 ed f1 ff ff       	jmp    8010622a <alltraps>

8010703d <vector191>:
.globl vector191
vector191:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $191
8010703f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107044:	e9 e1 f1 ff ff       	jmp    8010622a <alltraps>

80107049 <vector192>:
.globl vector192
vector192:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $192
8010704b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107050:	e9 d5 f1 ff ff       	jmp    8010622a <alltraps>

80107055 <vector193>:
.globl vector193
vector193:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $193
80107057:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010705c:	e9 c9 f1 ff ff       	jmp    8010622a <alltraps>

80107061 <vector194>:
.globl vector194
vector194:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $194
80107063:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107068:	e9 bd f1 ff ff       	jmp    8010622a <alltraps>

8010706d <vector195>:
.globl vector195
vector195:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $195
8010706f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107074:	e9 b1 f1 ff ff       	jmp    8010622a <alltraps>

80107079 <vector196>:
.globl vector196
vector196:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $196
8010707b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107080:	e9 a5 f1 ff ff       	jmp    8010622a <alltraps>

80107085 <vector197>:
.globl vector197
vector197:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $197
80107087:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010708c:	e9 99 f1 ff ff       	jmp    8010622a <alltraps>

80107091 <vector198>:
.globl vector198
vector198:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $198
80107093:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107098:	e9 8d f1 ff ff       	jmp    8010622a <alltraps>

8010709d <vector199>:
.globl vector199
vector199:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $199
8010709f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801070a4:	e9 81 f1 ff ff       	jmp    8010622a <alltraps>

801070a9 <vector200>:
.globl vector200
vector200:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $200
801070ab:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801070b0:	e9 75 f1 ff ff       	jmp    8010622a <alltraps>

801070b5 <vector201>:
.globl vector201
vector201:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $201
801070b7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801070bc:	e9 69 f1 ff ff       	jmp    8010622a <alltraps>

801070c1 <vector202>:
.globl vector202
vector202:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $202
801070c3:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801070c8:	e9 5d f1 ff ff       	jmp    8010622a <alltraps>

801070cd <vector203>:
.globl vector203
vector203:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $203
801070cf:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801070d4:	e9 51 f1 ff ff       	jmp    8010622a <alltraps>

801070d9 <vector204>:
.globl vector204
vector204:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $204
801070db:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801070e0:	e9 45 f1 ff ff       	jmp    8010622a <alltraps>

801070e5 <vector205>:
.globl vector205
vector205:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $205
801070e7:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070ec:	e9 39 f1 ff ff       	jmp    8010622a <alltraps>

801070f1 <vector206>:
.globl vector206
vector206:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $206
801070f3:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801070f8:	e9 2d f1 ff ff       	jmp    8010622a <alltraps>

801070fd <vector207>:
.globl vector207
vector207:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $207
801070ff:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107104:	e9 21 f1 ff ff       	jmp    8010622a <alltraps>

80107109 <vector208>:
.globl vector208
vector208:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $208
8010710b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107110:	e9 15 f1 ff ff       	jmp    8010622a <alltraps>

80107115 <vector209>:
.globl vector209
vector209:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $209
80107117:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010711c:	e9 09 f1 ff ff       	jmp    8010622a <alltraps>

80107121 <vector210>:
.globl vector210
vector210:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $210
80107123:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107128:	e9 fd f0 ff ff       	jmp    8010622a <alltraps>

8010712d <vector211>:
.globl vector211
vector211:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $211
8010712f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107134:	e9 f1 f0 ff ff       	jmp    8010622a <alltraps>

80107139 <vector212>:
.globl vector212
vector212:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $212
8010713b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107140:	e9 e5 f0 ff ff       	jmp    8010622a <alltraps>

80107145 <vector213>:
.globl vector213
vector213:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $213
80107147:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010714c:	e9 d9 f0 ff ff       	jmp    8010622a <alltraps>

80107151 <vector214>:
.globl vector214
vector214:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $214
80107153:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107158:	e9 cd f0 ff ff       	jmp    8010622a <alltraps>

8010715d <vector215>:
.globl vector215
vector215:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $215
8010715f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107164:	e9 c1 f0 ff ff       	jmp    8010622a <alltraps>

80107169 <vector216>:
.globl vector216
vector216:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $216
8010716b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107170:	e9 b5 f0 ff ff       	jmp    8010622a <alltraps>

80107175 <vector217>:
.globl vector217
vector217:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $217
80107177:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010717c:	e9 a9 f0 ff ff       	jmp    8010622a <alltraps>

80107181 <vector218>:
.globl vector218
vector218:
  pushl $0
80107181:	6a 00                	push   $0x0
  pushl $218
80107183:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107188:	e9 9d f0 ff ff       	jmp    8010622a <alltraps>

8010718d <vector219>:
.globl vector219
vector219:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $219
8010718f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107194:	e9 91 f0 ff ff       	jmp    8010622a <alltraps>

80107199 <vector220>:
.globl vector220
vector220:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $220
8010719b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801071a0:	e9 85 f0 ff ff       	jmp    8010622a <alltraps>

801071a5 <vector221>:
.globl vector221
vector221:
  pushl $0
801071a5:	6a 00                	push   $0x0
  pushl $221
801071a7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801071ac:	e9 79 f0 ff ff       	jmp    8010622a <alltraps>

801071b1 <vector222>:
.globl vector222
vector222:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $222
801071b3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801071b8:	e9 6d f0 ff ff       	jmp    8010622a <alltraps>

801071bd <vector223>:
.globl vector223
vector223:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $223
801071bf:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801071c4:	e9 61 f0 ff ff       	jmp    8010622a <alltraps>

801071c9 <vector224>:
.globl vector224
vector224:
  pushl $0
801071c9:	6a 00                	push   $0x0
  pushl $224
801071cb:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801071d0:	e9 55 f0 ff ff       	jmp    8010622a <alltraps>

801071d5 <vector225>:
.globl vector225
vector225:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $225
801071d7:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801071dc:	e9 49 f0 ff ff       	jmp    8010622a <alltraps>

801071e1 <vector226>:
.globl vector226
vector226:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $226
801071e3:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071e8:	e9 3d f0 ff ff       	jmp    8010622a <alltraps>

801071ed <vector227>:
.globl vector227
vector227:
  pushl $0
801071ed:	6a 00                	push   $0x0
  pushl $227
801071ef:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071f4:	e9 31 f0 ff ff       	jmp    8010622a <alltraps>

801071f9 <vector228>:
.globl vector228
vector228:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $228
801071fb:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107200:	e9 25 f0 ff ff       	jmp    8010622a <alltraps>

80107205 <vector229>:
.globl vector229
vector229:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $229
80107207:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010720c:	e9 19 f0 ff ff       	jmp    8010622a <alltraps>

80107211 <vector230>:
.globl vector230
vector230:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $230
80107213:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107218:	e9 0d f0 ff ff       	jmp    8010622a <alltraps>

8010721d <vector231>:
.globl vector231
vector231:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $231
8010721f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107224:	e9 01 f0 ff ff       	jmp    8010622a <alltraps>

80107229 <vector232>:
.globl vector232
vector232:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $232
8010722b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107230:	e9 f5 ef ff ff       	jmp    8010622a <alltraps>

80107235 <vector233>:
.globl vector233
vector233:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $233
80107237:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010723c:	e9 e9 ef ff ff       	jmp    8010622a <alltraps>

80107241 <vector234>:
.globl vector234
vector234:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $234
80107243:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107248:	e9 dd ef ff ff       	jmp    8010622a <alltraps>

8010724d <vector235>:
.globl vector235
vector235:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $235
8010724f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107254:	e9 d1 ef ff ff       	jmp    8010622a <alltraps>

80107259 <vector236>:
.globl vector236
vector236:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $236
8010725b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107260:	e9 c5 ef ff ff       	jmp    8010622a <alltraps>

80107265 <vector237>:
.globl vector237
vector237:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $237
80107267:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010726c:	e9 b9 ef ff ff       	jmp    8010622a <alltraps>

80107271 <vector238>:
.globl vector238
vector238:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $238
80107273:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107278:	e9 ad ef ff ff       	jmp    8010622a <alltraps>

8010727d <vector239>:
.globl vector239
vector239:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $239
8010727f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107284:	e9 a1 ef ff ff       	jmp    8010622a <alltraps>

80107289 <vector240>:
.globl vector240
vector240:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $240
8010728b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107290:	e9 95 ef ff ff       	jmp    8010622a <alltraps>

80107295 <vector241>:
.globl vector241
vector241:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $241
80107297:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010729c:	e9 89 ef ff ff       	jmp    8010622a <alltraps>

801072a1 <vector242>:
.globl vector242
vector242:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $242
801072a3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801072a8:	e9 7d ef ff ff       	jmp    8010622a <alltraps>

801072ad <vector243>:
.globl vector243
vector243:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $243
801072af:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801072b4:	e9 71 ef ff ff       	jmp    8010622a <alltraps>

801072b9 <vector244>:
.globl vector244
vector244:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $244
801072bb:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801072c0:	e9 65 ef ff ff       	jmp    8010622a <alltraps>

801072c5 <vector245>:
.globl vector245
vector245:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $245
801072c7:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801072cc:	e9 59 ef ff ff       	jmp    8010622a <alltraps>

801072d1 <vector246>:
.globl vector246
vector246:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $246
801072d3:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801072d8:	e9 4d ef ff ff       	jmp    8010622a <alltraps>

801072dd <vector247>:
.globl vector247
vector247:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $247
801072df:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801072e4:	e9 41 ef ff ff       	jmp    8010622a <alltraps>

801072e9 <vector248>:
.globl vector248
vector248:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $248
801072eb:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072f0:	e9 35 ef ff ff       	jmp    8010622a <alltraps>

801072f5 <vector249>:
.globl vector249
vector249:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $249
801072f7:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801072fc:	e9 29 ef ff ff       	jmp    8010622a <alltraps>

80107301 <vector250>:
.globl vector250
vector250:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $250
80107303:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107308:	e9 1d ef ff ff       	jmp    8010622a <alltraps>

8010730d <vector251>:
.globl vector251
vector251:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $251
8010730f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107314:	e9 11 ef ff ff       	jmp    8010622a <alltraps>

80107319 <vector252>:
.globl vector252
vector252:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $252
8010731b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107320:	e9 05 ef ff ff       	jmp    8010622a <alltraps>

80107325 <vector253>:
.globl vector253
vector253:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $253
80107327:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010732c:	e9 f9 ee ff ff       	jmp    8010622a <alltraps>

80107331 <vector254>:
.globl vector254
vector254:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $254
80107333:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107338:	e9 ed ee ff ff       	jmp    8010622a <alltraps>

8010733d <vector255>:
.globl vector255
vector255:
  pushl $0
8010733d:	6a 00                	push   $0x0
  pushl $255
8010733f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107344:	e9 e1 ee ff ff       	jmp    8010622a <alltraps>

80107349 <lgdt>:
{
80107349:	55                   	push   %ebp
8010734a:	89 e5                	mov    %esp,%ebp
8010734c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010734f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107352:	83 e8 01             	sub    $0x1,%eax
80107355:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107359:	8b 45 08             	mov    0x8(%ebp),%eax
8010735c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107360:	8b 45 08             	mov    0x8(%ebp),%eax
80107363:	c1 e8 10             	shr    $0x10,%eax
80107366:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010736a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010736d:	0f 01 10             	lgdtl  (%eax)
}
80107370:	90                   	nop
80107371:	c9                   	leave
80107372:	c3                   	ret

80107373 <ltr>:
{
80107373:	55                   	push   %ebp
80107374:	89 e5                	mov    %esp,%ebp
80107376:	83 ec 04             	sub    $0x4,%esp
80107379:	8b 45 08             	mov    0x8(%ebp),%eax
8010737c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107380:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107384:	0f 00 d8             	ltr    %eax
}
80107387:	90                   	nop
80107388:	c9                   	leave
80107389:	c3                   	ret

8010738a <lcr3>:

static inline void
lcr3(uint val)
{
8010738a:	55                   	push   %ebp
8010738b:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010738d:	8b 45 08             	mov    0x8(%ebp),%eax
80107390:	0f 22 d8             	mov    %eax,%cr3
}
80107393:	90                   	nop
80107394:	5d                   	pop    %ebp
80107395:	c3                   	ret

80107396 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107396:	55                   	push   %ebp
80107397:	89 e5                	mov    %esp,%ebp
80107399:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010739c:	e8 de ca ff ff       	call   80103e7f <cpuid>
801073a1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801073a7:	05 c0 9a 11 80       	add    $0x80119ac0,%eax
801073ac:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801073af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801073b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801073c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801073c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073cb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073cf:	83 e2 f0             	and    $0xfffffff0,%edx
801073d2:	83 ca 0a             	or     $0xa,%edx
801073d5:	88 50 7d             	mov    %dl,0x7d(%eax)
801073d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073db:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073df:	83 ca 10             	or     $0x10,%edx
801073e2:	88 50 7d             	mov    %dl,0x7d(%eax)
801073e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073ec:	83 e2 9f             	and    $0xffffff9f,%edx
801073ef:	88 50 7d             	mov    %dl,0x7d(%eax)
801073f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801073f9:	83 ca 80             	or     $0xffffff80,%edx
801073fc:	88 50 7d             	mov    %dl,0x7d(%eax)
801073ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107402:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107406:	83 ca 0f             	or     $0xf,%edx
80107409:	88 50 7e             	mov    %dl,0x7e(%eax)
8010740c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010740f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107413:	83 e2 ef             	and    $0xffffffef,%edx
80107416:	88 50 7e             	mov    %dl,0x7e(%eax)
80107419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010741c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107420:	83 e2 df             	and    $0xffffffdf,%edx
80107423:	88 50 7e             	mov    %dl,0x7e(%eax)
80107426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107429:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010742d:	83 ca 40             	or     $0x40,%edx
80107430:	88 50 7e             	mov    %dl,0x7e(%eax)
80107433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107436:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010743a:	83 ca 80             	or     $0xffffff80,%edx
8010743d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107443:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010744a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107451:	ff ff 
80107453:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107456:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010745d:	00 00 
8010745f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107462:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107473:	83 e2 f0             	and    $0xfffffff0,%edx
80107476:	83 ca 02             	or     $0x2,%edx
80107479:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010747f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107482:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107489:	83 ca 10             	or     $0x10,%edx
8010748c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107495:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010749c:	83 e2 9f             	and    $0xffffff9f,%edx
8010749f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801074af:	83 ca 80             	or     $0xffffff80,%edx
801074b2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074c2:	83 ca 0f             	or     $0xf,%edx
801074c5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ce:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074d5:	83 e2 ef             	and    $0xffffffef,%edx
801074d8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074e1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074e8:	83 e2 df             	and    $0xffffffdf,%edx
801074eb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801074fb:	83 ca 40             	or     $0x40,%edx
801074fe:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107507:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010750e:	83 ca 80             	or     $0xffffff80,%edx
80107511:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010751a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107524:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010752b:	ff ff 
8010752d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107530:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107537:	00 00 
80107539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010753c:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107546:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010754d:	83 e2 f0             	and    $0xfffffff0,%edx
80107550:	83 ca 0a             	or     $0xa,%edx
80107553:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107563:	83 ca 10             	or     $0x10,%edx
80107566:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010756c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010756f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107576:	83 ca 60             	or     $0x60,%edx
80107579:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010757f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107582:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107589:	83 ca 80             	or     $0xffffff80,%edx
8010758c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107595:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010759c:	83 ca 0f             	or     $0xf,%edx
8010759f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075af:	83 e2 ef             	and    $0xffffffef,%edx
801075b2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075c2:	83 e2 df             	and    $0xffffffdf,%edx
801075c5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ce:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075d5:	83 ca 40             	or     $0x40,%edx
801075d8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801075e8:	83 ca 80             	or     $0xffffff80,%edx
801075eb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801075f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801075fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075fe:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107605:	ff ff 
80107607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107611:	00 00 
80107613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107616:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010761d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107620:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107627:	83 e2 f0             	and    $0xfffffff0,%edx
8010762a:	83 ca 02             	or     $0x2,%edx
8010762d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107636:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010763d:	83 ca 10             	or     $0x10,%edx
80107640:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107649:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107650:	83 ca 60             	or     $0x60,%edx
80107653:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010765c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107663:	83 ca 80             	or     $0xffffff80,%edx
80107666:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010766c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107676:	83 ca 0f             	or     $0xf,%edx
80107679:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010767f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107682:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107689:	83 e2 ef             	and    $0xffffffef,%edx
8010768c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107695:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010769c:	83 e2 df             	and    $0xffffffdf,%edx
8010769f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076af:	83 ca 40             	or     $0x40,%edx
801076b2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076bb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801076c2:	83 ca 80             	or     $0xffffff80,%edx
801076c5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801076cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ce:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801076d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d8:	83 c0 70             	add    $0x70,%eax
801076db:	83 ec 08             	sub    $0x8,%esp
801076de:	6a 30                	push   $0x30
801076e0:	50                   	push   %eax
801076e1:	e8 63 fc ff ff       	call   80107349 <lgdt>
801076e6:	83 c4 10             	add    $0x10,%esp
}
801076e9:	90                   	nop
801076ea:	c9                   	leave
801076eb:	c3                   	ret

801076ec <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801076ec:	55                   	push   %ebp
801076ed:	89 e5                	mov    %esp,%ebp
801076ef:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801076f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801076f5:	c1 e8 16             	shr    $0x16,%eax
801076f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801076ff:	8b 45 08             	mov    0x8(%ebp),%eax
80107702:	01 d0                	add    %edx,%eax
80107704:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107707:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010770a:	8b 00                	mov    (%eax),%eax
8010770c:	83 e0 01             	and    $0x1,%eax
8010770f:	85 c0                	test   %eax,%eax
80107711:	74 14                	je     80107727 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107716:	8b 00                	mov    (%eax),%eax
80107718:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010771d:	05 00 00 00 80       	add    $0x80000000,%eax
80107722:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107725:	eb 42                	jmp    80107769 <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107727:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010772b:	74 0e                	je     8010773b <walkpgdir+0x4f>
8010772d:	e8 58 b5 ff ff       	call   80102c8a <kalloc>
80107732:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107735:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107739:	75 07                	jne    80107742 <walkpgdir+0x56>
      return 0;
8010773b:	b8 00 00 00 00       	mov    $0x0,%eax
80107740:	eb 3e                	jmp    80107780 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107742:	83 ec 04             	sub    $0x4,%esp
80107745:	68 00 10 00 00       	push   $0x1000
8010774a:	6a 00                	push   $0x0
8010774c:	ff 75 f4             	push   -0xc(%ebp)
8010774f:	e8 29 d7 ff ff       	call   80104e7d <memset>
80107754:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775a:	05 00 00 00 80       	add    $0x80000000,%eax
8010775f:	83 c8 07             	or     $0x7,%eax
80107762:	89 c2                	mov    %eax,%edx
80107764:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107767:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107769:	8b 45 0c             	mov    0xc(%ebp),%eax
8010776c:	c1 e8 0c             	shr    $0xc,%eax
8010776f:	25 ff 03 00 00       	and    $0x3ff,%eax
80107774:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010777b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777e:	01 d0                	add    %edx,%eax
}
80107780:	c9                   	leave
80107781:	c3                   	ret

80107782 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107782:	55                   	push   %ebp
80107783:	89 e5                	mov    %esp,%ebp
80107785:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107788:	8b 45 0c             	mov    0xc(%ebp),%eax
8010778b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107790:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107793:	8b 55 0c             	mov    0xc(%ebp),%edx
80107796:	8b 45 10             	mov    0x10(%ebp),%eax
80107799:	01 d0                	add    %edx,%eax
8010779b:	83 e8 01             	sub    $0x1,%eax
8010779e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801077a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801077a6:	83 ec 04             	sub    $0x4,%esp
801077a9:	6a 01                	push   $0x1
801077ab:	ff 75 f4             	push   -0xc(%ebp)
801077ae:	ff 75 08             	push   0x8(%ebp)
801077b1:	e8 36 ff ff ff       	call   801076ec <walkpgdir>
801077b6:	83 c4 10             	add    $0x10,%esp
801077b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801077bc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801077c0:	75 07                	jne    801077c9 <mappages+0x47>
      return -1;
801077c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077c7:	eb 47                	jmp    80107810 <mappages+0x8e>
    if(*pte & PTE_P)
801077c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077cc:	8b 00                	mov    (%eax),%eax
801077ce:	83 e0 01             	and    $0x1,%eax
801077d1:	85 c0                	test   %eax,%eax
801077d3:	74 0d                	je     801077e2 <mappages+0x60>
      panic("remap");
801077d5:	83 ec 0c             	sub    $0xc,%esp
801077d8:	68 38 aa 10 80       	push   $0x8010aa38
801077dd:	e8 c7 8d ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801077e2:	8b 45 18             	mov    0x18(%ebp),%eax
801077e5:	0b 45 14             	or     0x14(%ebp),%eax
801077e8:	83 c8 01             	or     $0x1,%eax
801077eb:	89 c2                	mov    %eax,%edx
801077ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801077f0:	89 10                	mov    %edx,(%eax)
    if(a == last)
801077f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801077f8:	74 10                	je     8010780a <mappages+0x88>
      break;
    a += PGSIZE;
801077fa:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107801:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107808:	eb 9c                	jmp    801077a6 <mappages+0x24>
      break;
8010780a:	90                   	nop
  }
  return 0;
8010780b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107810:	c9                   	leave
80107811:	c3                   	ret

80107812 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107812:	55                   	push   %ebp
80107813:	89 e5                	mov    %esp,%ebp
80107815:	53                   	push   %ebx
80107816:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
80107819:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107820:	a1 90 9d 11 80       	mov    0x80119d90,%eax
80107825:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010782a:	29 c2                	sub    %eax,%edx
8010782c:	89 d0                	mov    %edx,%eax
8010782e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107831:	a1 88 9d 11 80       	mov    0x80119d88,%eax
80107836:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107839:	8b 15 88 9d 11 80    	mov    0x80119d88,%edx
8010783f:	a1 90 9d 11 80       	mov    0x80119d90,%eax
80107844:	01 d0                	add    %edx,%eax
80107846:	89 45 e8             	mov    %eax,-0x18(%ebp)
80107849:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107853:	83 c0 30             	add    $0x30,%eax
80107856:	8b 55 e0             	mov    -0x20(%ebp),%edx
80107859:	89 10                	mov    %edx,(%eax)
8010785b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010785e:	89 50 04             	mov    %edx,0x4(%eax)
80107861:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107864:	89 50 08             	mov    %edx,0x8(%eax)
80107867:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010786a:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010786d:	e8 18 b4 ff ff       	call   80102c8a <kalloc>
80107872:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107875:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107879:	75 07                	jne    80107882 <setupkvm+0x70>
    return 0;
8010787b:	b8 00 00 00 00       	mov    $0x0,%eax
80107880:	eb 78                	jmp    801078fa <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107882:	83 ec 04             	sub    $0x4,%esp
80107885:	68 00 10 00 00       	push   $0x1000
8010788a:	6a 00                	push   $0x0
8010788c:	ff 75 f0             	push   -0x10(%ebp)
8010788f:	e8 e9 d5 ff ff       	call   80104e7d <memset>
80107894:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107897:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
8010789e:	eb 4e                	jmp    801078ee <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801078a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a3:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801078a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a9:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801078ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078af:	8b 58 08             	mov    0x8(%eax),%ebx
801078b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b5:	8b 40 04             	mov    0x4(%eax),%eax
801078b8:	29 c3                	sub    %eax,%ebx
801078ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bd:	8b 00                	mov    (%eax),%eax
801078bf:	83 ec 0c             	sub    $0xc,%esp
801078c2:	51                   	push   %ecx
801078c3:	52                   	push   %edx
801078c4:	53                   	push   %ebx
801078c5:	50                   	push   %eax
801078c6:	ff 75 f0             	push   -0x10(%ebp)
801078c9:	e8 b4 fe ff ff       	call   80107782 <mappages>
801078ce:	83 c4 20             	add    $0x20,%esp
801078d1:	85 c0                	test   %eax,%eax
801078d3:	79 15                	jns    801078ea <setupkvm+0xd8>
      freevm(pgdir);
801078d5:	83 ec 0c             	sub    $0xc,%esp
801078d8:	ff 75 f0             	push   -0x10(%ebp)
801078db:	e8 f5 04 00 00       	call   80107dd5 <freevm>
801078e0:	83 c4 10             	add    $0x10,%esp
      return 0;
801078e3:	b8 00 00 00 00       	mov    $0x0,%eax
801078e8:	eb 10                	jmp    801078fa <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078ea:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801078ee:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801078f5:	72 a9                	jb     801078a0 <setupkvm+0x8e>
    }
  return pgdir;
801078f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801078fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801078fd:	c9                   	leave
801078fe:	c3                   	ret

801078ff <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801078ff:	55                   	push   %ebp
80107900:	89 e5                	mov    %esp,%ebp
80107902:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107905:	e8 08 ff ff ff       	call   80107812 <setupkvm>
8010790a:	a3 bc 9a 11 80       	mov    %eax,0x80119abc
  switchkvm();
8010790f:	e8 03 00 00 00       	call   80107917 <switchkvm>
}
80107914:	90                   	nop
80107915:	c9                   	leave
80107916:	c3                   	ret

80107917 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107917:	55                   	push   %ebp
80107918:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010791a:	a1 bc 9a 11 80       	mov    0x80119abc,%eax
8010791f:	05 00 00 00 80       	add    $0x80000000,%eax
80107924:	50                   	push   %eax
80107925:	e8 60 fa ff ff       	call   8010738a <lcr3>
8010792a:	83 c4 04             	add    $0x4,%esp
}
8010792d:	90                   	nop
8010792e:	c9                   	leave
8010792f:	c3                   	ret

80107930 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107930:	55                   	push   %ebp
80107931:	89 e5                	mov    %esp,%ebp
80107933:	56                   	push   %esi
80107934:	53                   	push   %ebx
80107935:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80107938:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010793c:	75 0d                	jne    8010794b <switchuvm+0x1b>
    panic("switchuvm: no process");
8010793e:	83 ec 0c             	sub    $0xc,%esp
80107941:	68 3e aa 10 80       	push   $0x8010aa3e
80107946:	e8 5e 8c ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010794b:	8b 45 08             	mov    0x8(%ebp),%eax
8010794e:	8b 40 08             	mov    0x8(%eax),%eax
80107951:	85 c0                	test   %eax,%eax
80107953:	75 0d                	jne    80107962 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107955:	83 ec 0c             	sub    $0xc,%esp
80107958:	68 54 aa 10 80       	push   $0x8010aa54
8010795d:	e8 47 8c ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107962:	8b 45 08             	mov    0x8(%ebp),%eax
80107965:	8b 40 04             	mov    0x4(%eax),%eax
80107968:	85 c0                	test   %eax,%eax
8010796a:	75 0d                	jne    80107979 <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010796c:	83 ec 0c             	sub    $0xc,%esp
8010796f:	68 69 aa 10 80       	push   $0x8010aa69
80107974:	e8 30 8c ff ff       	call   801005a9 <panic>

  pushcli();
80107979:	e8 f4 d3 ff ff       	call   80104d72 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010797e:	e8 17 c5 ff ff       	call   80103e9a <mycpu>
80107983:	89 c3                	mov    %eax,%ebx
80107985:	e8 10 c5 ff ff       	call   80103e9a <mycpu>
8010798a:	83 c0 08             	add    $0x8,%eax
8010798d:	89 c6                	mov    %eax,%esi
8010798f:	e8 06 c5 ff ff       	call   80103e9a <mycpu>
80107994:	83 c0 08             	add    $0x8,%eax
80107997:	c1 e8 10             	shr    $0x10,%eax
8010799a:	88 45 f7             	mov    %al,-0x9(%ebp)
8010799d:	e8 f8 c4 ff ff       	call   80103e9a <mycpu>
801079a2:	83 c0 08             	add    $0x8,%eax
801079a5:	c1 e8 18             	shr    $0x18,%eax
801079a8:	89 c2                	mov    %eax,%edx
801079aa:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801079b1:	67 00 
801079b3:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801079ba:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801079be:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801079c4:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079cb:	83 e0 f0             	and    $0xfffffff0,%eax
801079ce:	83 c8 09             	or     $0x9,%eax
801079d1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079d7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079de:	83 c8 10             	or     $0x10,%eax
801079e1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079e7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079ee:	83 e0 9f             	and    $0xffffff9f,%eax
801079f1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801079f7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801079fe:	83 c8 80             	or     $0xffffff80,%eax
80107a01:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80107a07:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a0e:	83 e0 f0             	and    $0xfffffff0,%eax
80107a11:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a17:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a1e:	83 e0 ef             	and    $0xffffffef,%eax
80107a21:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a27:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a2e:	83 e0 df             	and    $0xffffffdf,%eax
80107a31:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a37:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a3e:	83 c8 40             	or     $0x40,%eax
80107a41:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a47:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107a4e:	83 e0 7f             	and    $0x7f,%eax
80107a51:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107a57:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107a5d:	e8 38 c4 ff ff       	call   80103e9a <mycpu>
80107a62:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a69:	83 e2 ef             	and    $0xffffffef,%edx
80107a6c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107a72:	e8 23 c4 ff ff       	call   80103e9a <mycpu>
80107a77:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a80:	8b 40 08             	mov    0x8(%eax),%eax
80107a83:	89 c3                	mov    %eax,%ebx
80107a85:	e8 10 c4 ff ff       	call   80103e9a <mycpu>
80107a8a:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107a90:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107a93:	e8 02 c4 ff ff       	call   80103e9a <mycpu>
80107a98:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107a9e:	83 ec 0c             	sub    $0xc,%esp
80107aa1:	6a 28                	push   $0x28
80107aa3:	e8 cb f8 ff ff       	call   80107373 <ltr>
80107aa8:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107aab:	8b 45 08             	mov    0x8(%ebp),%eax
80107aae:	8b 40 04             	mov    0x4(%eax),%eax
80107ab1:	05 00 00 00 80       	add    $0x80000000,%eax
80107ab6:	83 ec 0c             	sub    $0xc,%esp
80107ab9:	50                   	push   %eax
80107aba:	e8 cb f8 ff ff       	call   8010738a <lcr3>
80107abf:	83 c4 10             	add    $0x10,%esp
  popcli();
80107ac2:	e8 f8 d2 ff ff       	call   80104dbf <popcli>
}
80107ac7:	90                   	nop
80107ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107acb:	5b                   	pop    %ebx
80107acc:	5e                   	pop    %esi
80107acd:	5d                   	pop    %ebp
80107ace:	c3                   	ret

80107acf <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107acf:	55                   	push   %ebp
80107ad0:	89 e5                	mov    %esp,%ebp
80107ad2:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80107ad5:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107adc:	76 0d                	jbe    80107aeb <inituvm+0x1c>
    panic("inituvm: more than a page");
80107ade:	83 ec 0c             	sub    $0xc,%esp
80107ae1:	68 7d aa 10 80       	push   $0x8010aa7d
80107ae6:	e8 be 8a ff ff       	call   801005a9 <panic>
  mem = kalloc();
80107aeb:	e8 9a b1 ff ff       	call   80102c8a <kalloc>
80107af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107af3:	83 ec 04             	sub    $0x4,%esp
80107af6:	68 00 10 00 00       	push   $0x1000
80107afb:	6a 00                	push   $0x0
80107afd:	ff 75 f4             	push   -0xc(%ebp)
80107b00:	e8 78 d3 ff ff       	call   80104e7d <memset>
80107b05:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	05 00 00 00 80       	add    $0x80000000,%eax
80107b10:	83 ec 0c             	sub    $0xc,%esp
80107b13:	6a 06                	push   $0x6
80107b15:	50                   	push   %eax
80107b16:	68 00 10 00 00       	push   $0x1000
80107b1b:	6a 00                	push   $0x0
80107b1d:	ff 75 08             	push   0x8(%ebp)
80107b20:	e8 5d fc ff ff       	call   80107782 <mappages>
80107b25:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80107b28:	83 ec 04             	sub    $0x4,%esp
80107b2b:	ff 75 10             	push   0x10(%ebp)
80107b2e:	ff 75 0c             	push   0xc(%ebp)
80107b31:	ff 75 f4             	push   -0xc(%ebp)
80107b34:	e8 03 d4 ff ff       	call   80104f3c <memmove>
80107b39:	83 c4 10             	add    $0x10,%esp
}
80107b3c:	90                   	nop
80107b3d:	c9                   	leave
80107b3e:	c3                   	ret

80107b3f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107b3f:	55                   	push   %ebp
80107b40:	89 e5                	mov    %esp,%ebp
80107b42:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b48:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b4d:	85 c0                	test   %eax,%eax
80107b4f:	74 0d                	je     80107b5e <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107b51:	83 ec 0c             	sub    $0xc,%esp
80107b54:	68 98 aa 10 80       	push   $0x8010aa98
80107b59:	e8 4b 8a ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107b5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b65:	e9 8f 00 00 00       	jmp    80107bf9 <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b70:	01 d0                	add    %edx,%eax
80107b72:	83 ec 04             	sub    $0x4,%esp
80107b75:	6a 00                	push   $0x0
80107b77:	50                   	push   %eax
80107b78:	ff 75 08             	push   0x8(%ebp)
80107b7b:	e8 6c fb ff ff       	call   801076ec <walkpgdir>
80107b80:	83 c4 10             	add    $0x10,%esp
80107b83:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107b86:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107b8a:	75 0d                	jne    80107b99 <loaduvm+0x5a>
      panic("loaduvm: address should exist");
80107b8c:	83 ec 0c             	sub    $0xc,%esp
80107b8f:	68 bb aa 10 80       	push   $0x8010aabb
80107b94:	e8 10 8a ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107b99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b9c:	8b 00                	mov    (%eax),%eax
80107b9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ba3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107ba6:	8b 45 18             	mov    0x18(%ebp),%eax
80107ba9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107bac:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107bb1:	77 0b                	ja     80107bbe <loaduvm+0x7f>
      n = sz - i;
80107bb3:	8b 45 18             	mov    0x18(%ebp),%eax
80107bb6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107bbc:	eb 07                	jmp    80107bc5 <loaduvm+0x86>
    else
      n = PGSIZE;
80107bbe:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107bc5:	8b 55 14             	mov    0x14(%ebp),%edx
80107bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcb:	01 d0                	add    %edx,%eax
80107bcd:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107bd0:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107bd6:	ff 75 f0             	push   -0x10(%ebp)
80107bd9:	50                   	push   %eax
80107bda:	52                   	push   %edx
80107bdb:	ff 75 10             	push   0x10(%ebp)
80107bde:	e8 fb a2 ff ff       	call   80101ede <readi>
80107be3:	83 c4 10             	add    $0x10,%esp
80107be6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80107be9:	74 07                	je     80107bf2 <loaduvm+0xb3>
      return -1;
80107beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bf0:	eb 18                	jmp    80107c0a <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
80107bf2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfc:	3b 45 18             	cmp    0x18(%ebp),%eax
80107bff:	0f 82 65 ff ff ff    	jb     80107b6a <loaduvm+0x2b>
  }
  return 0;
80107c05:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c0a:	c9                   	leave
80107c0b:	c3                   	ret

80107c0c <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107c0c:	55                   	push   %ebp
80107c0d:	89 e5                	mov    %esp,%ebp
80107c0f:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107c12:	8b 45 10             	mov    0x10(%ebp),%eax
80107c15:	85 c0                	test   %eax,%eax
80107c17:	79 0a                	jns    80107c23 <allocuvm+0x17>
    return 0;
80107c19:	b8 00 00 00 00       	mov    $0x0,%eax
80107c1e:	e9 ec 00 00 00       	jmp    80107d0f <allocuvm+0x103>
  if(newsz < oldsz)
80107c23:	8b 45 10             	mov    0x10(%ebp),%eax
80107c26:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107c29:	73 08                	jae    80107c33 <allocuvm+0x27>
    return oldsz;
80107c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c2e:	e9 dc 00 00 00       	jmp    80107d0f <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107c33:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c36:	05 ff 0f 00 00       	add    $0xfff,%eax
80107c3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107c43:	e9 b8 00 00 00       	jmp    80107d00 <allocuvm+0xf4>
    mem = kalloc();
80107c48:	e8 3d b0 ff ff       	call   80102c8a <kalloc>
80107c4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107c50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c54:	75 2e                	jne    80107c84 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107c56:	83 ec 0c             	sub    $0xc,%esp
80107c59:	68 d9 aa 10 80       	push   $0x8010aad9
80107c5e:	e8 91 87 ff ff       	call   801003f4 <cprintf>
80107c63:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107c66:	83 ec 04             	sub    $0x4,%esp
80107c69:	ff 75 0c             	push   0xc(%ebp)
80107c6c:	ff 75 10             	push   0x10(%ebp)
80107c6f:	ff 75 08             	push   0x8(%ebp)
80107c72:	e8 9a 00 00 00       	call   80107d11 <deallocuvm>
80107c77:	83 c4 10             	add    $0x10,%esp
      return 0;
80107c7a:	b8 00 00 00 00       	mov    $0x0,%eax
80107c7f:	e9 8b 00 00 00       	jmp    80107d0f <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107c84:	83 ec 04             	sub    $0x4,%esp
80107c87:	68 00 10 00 00       	push   $0x1000
80107c8c:	6a 00                	push   $0x0
80107c8e:	ff 75 f0             	push   -0x10(%ebp)
80107c91:	e8 e7 d1 ff ff       	call   80104e7d <memset>
80107c96:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c9c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca5:	83 ec 0c             	sub    $0xc,%esp
80107ca8:	6a 06                	push   $0x6
80107caa:	52                   	push   %edx
80107cab:	68 00 10 00 00       	push   $0x1000
80107cb0:	50                   	push   %eax
80107cb1:	ff 75 08             	push   0x8(%ebp)
80107cb4:	e8 c9 fa ff ff       	call   80107782 <mappages>
80107cb9:	83 c4 20             	add    $0x20,%esp
80107cbc:	85 c0                	test   %eax,%eax
80107cbe:	79 39                	jns    80107cf9 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80107cc0:	83 ec 0c             	sub    $0xc,%esp
80107cc3:	68 f1 aa 10 80       	push   $0x8010aaf1
80107cc8:	e8 27 87 ff ff       	call   801003f4 <cprintf>
80107ccd:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107cd0:	83 ec 04             	sub    $0x4,%esp
80107cd3:	ff 75 0c             	push   0xc(%ebp)
80107cd6:	ff 75 10             	push   0x10(%ebp)
80107cd9:	ff 75 08             	push   0x8(%ebp)
80107cdc:	e8 30 00 00 00       	call   80107d11 <deallocuvm>
80107ce1:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80107ce4:	83 ec 0c             	sub    $0xc,%esp
80107ce7:	ff 75 f0             	push   -0x10(%ebp)
80107cea:	e8 01 af ff ff       	call   80102bf0 <kfree>
80107cef:	83 c4 10             	add    $0x10,%esp
      return 0;
80107cf2:	b8 00 00 00 00       	mov    $0x0,%eax
80107cf7:	eb 16                	jmp    80107d0f <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
80107cf9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	3b 45 10             	cmp    0x10(%ebp),%eax
80107d06:	0f 82 3c ff ff ff    	jb     80107c48 <allocuvm+0x3c>
    }
  }
  return newsz;
80107d0c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107d0f:	c9                   	leave
80107d10:	c3                   	ret

80107d11 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d11:	55                   	push   %ebp
80107d12:	89 e5                	mov    %esp,%ebp
80107d14:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107d17:	8b 45 10             	mov    0x10(%ebp),%eax
80107d1a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d1d:	72 08                	jb     80107d27 <deallocuvm+0x16>
    return oldsz;
80107d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d22:	e9 ac 00 00 00       	jmp    80107dd3 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107d27:	8b 45 10             	mov    0x10(%ebp),%eax
80107d2a:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107d37:	e9 88 00 00 00       	jmp    80107dc4 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3f:	83 ec 04             	sub    $0x4,%esp
80107d42:	6a 00                	push   $0x0
80107d44:	50                   	push   %eax
80107d45:	ff 75 08             	push   0x8(%ebp)
80107d48:	e8 9f f9 ff ff       	call   801076ec <walkpgdir>
80107d4d:	83 c4 10             	add    $0x10,%esp
80107d50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107d53:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d57:	75 16                	jne    80107d6f <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	c1 e8 16             	shr    $0x16,%eax
80107d5f:	83 c0 01             	add    $0x1,%eax
80107d62:	c1 e0 16             	shl    $0x16,%eax
80107d65:	2d 00 10 00 00       	sub    $0x1000,%eax
80107d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d6d:	eb 4e                	jmp    80107dbd <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d72:	8b 00                	mov    (%eax),%eax
80107d74:	83 e0 01             	and    $0x1,%eax
80107d77:	85 c0                	test   %eax,%eax
80107d79:	74 42                	je     80107dbd <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80107d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d7e:	8b 00                	mov    (%eax),%eax
80107d80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d85:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107d88:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107d8c:	75 0d                	jne    80107d9b <deallocuvm+0x8a>
        panic("kfree");
80107d8e:	83 ec 0c             	sub    $0xc,%esp
80107d91:	68 0d ab 10 80       	push   $0x8010ab0d
80107d96:	e8 0e 88 ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
80107d9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d9e:	05 00 00 00 80       	add    $0x80000000,%eax
80107da3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107da6:	83 ec 0c             	sub    $0xc,%esp
80107da9:	ff 75 e8             	push   -0x18(%ebp)
80107dac:	e8 3f ae ff ff       	call   80102bf0 <kfree>
80107db1:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107db7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80107dbd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107dca:	0f 82 6c ff ff ff    	jb     80107d3c <deallocuvm+0x2b>
    }
  }
  return newsz;
80107dd0:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107dd3:	c9                   	leave
80107dd4:	c3                   	ret

80107dd5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107dd5:	55                   	push   %ebp
80107dd6:	89 e5                	mov    %esp,%ebp
80107dd8:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80107ddb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ddf:	75 0d                	jne    80107dee <freevm+0x19>
    panic("freevm: no pgdir");
80107de1:	83 ec 0c             	sub    $0xc,%esp
80107de4:	68 13 ab 10 80       	push   $0x8010ab13
80107de9:	e8 bb 87 ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107dee:	83 ec 04             	sub    $0x4,%esp
80107df1:	6a 00                	push   $0x0
80107df3:	68 00 00 00 80       	push   $0x80000000
80107df8:	ff 75 08             	push   0x8(%ebp)
80107dfb:	e8 11 ff ff ff       	call   80107d11 <deallocuvm>
80107e00:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e0a:	eb 48                	jmp    80107e54 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
80107e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e16:	8b 45 08             	mov    0x8(%ebp),%eax
80107e19:	01 d0                	add    %edx,%eax
80107e1b:	8b 00                	mov    (%eax),%eax
80107e1d:	83 e0 01             	and    $0x1,%eax
80107e20:	85 c0                	test   %eax,%eax
80107e22:	74 2c                	je     80107e50 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e2e:	8b 45 08             	mov    0x8(%ebp),%eax
80107e31:	01 d0                	add    %edx,%eax
80107e33:	8b 00                	mov    (%eax),%eax
80107e35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e3a:	05 00 00 00 80       	add    $0x80000000,%eax
80107e3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107e42:	83 ec 0c             	sub    $0xc,%esp
80107e45:	ff 75 f0             	push   -0x10(%ebp)
80107e48:	e8 a3 ad ff ff       	call   80102bf0 <kfree>
80107e4d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107e50:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e54:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107e5b:	76 af                	jbe    80107e0c <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107e5d:	83 ec 0c             	sub    $0xc,%esp
80107e60:	ff 75 08             	push   0x8(%ebp)
80107e63:	e8 88 ad ff ff       	call   80102bf0 <kfree>
80107e68:	83 c4 10             	add    $0x10,%esp
}
80107e6b:	90                   	nop
80107e6c:	c9                   	leave
80107e6d:	c3                   	ret

80107e6e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107e6e:	55                   	push   %ebp
80107e6f:	89 e5                	mov    %esp,%ebp
80107e71:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107e74:	83 ec 04             	sub    $0x4,%esp
80107e77:	6a 00                	push   $0x0
80107e79:	ff 75 0c             	push   0xc(%ebp)
80107e7c:	ff 75 08             	push   0x8(%ebp)
80107e7f:	e8 68 f8 ff ff       	call   801076ec <walkpgdir>
80107e84:	83 c4 10             	add    $0x10,%esp
80107e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107e8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e8e:	75 0d                	jne    80107e9d <clearpteu+0x2f>
    panic("clearpteu");
80107e90:	83 ec 0c             	sub    $0xc,%esp
80107e93:	68 24 ab 10 80       	push   $0x8010ab24
80107e98:	e8 0c 87 ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
80107e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea0:	8b 00                	mov    (%eax),%eax
80107ea2:	83 e0 fb             	and    $0xfffffffb,%eax
80107ea5:	89 c2                	mov    %eax,%edx
80107ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaa:	89 10                	mov    %edx,(%eax)
}
80107eac:	90                   	nop
80107ead:	c9                   	leave
80107eae:	c3                   	ret

80107eaf <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107eaf:	55                   	push   %ebp
80107eb0:	89 e5                	mov    %esp,%ebp
80107eb2:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107eb5:	e8 58 f9 ff ff       	call   80107812 <setupkvm>
80107eba:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ebd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ec1:	75 0a                	jne    80107ecd <copyuvm+0x1e>
    return 0;
80107ec3:	b8 00 00 00 00       	mov    $0x0,%eax
80107ec8:	e9 eb 00 00 00       	jmp    80107fb8 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80107ecd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ed4:	e9 b7 00 00 00       	jmp    80107f90 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edc:	83 ec 04             	sub    $0x4,%esp
80107edf:	6a 00                	push   $0x0
80107ee1:	50                   	push   %eax
80107ee2:	ff 75 08             	push   0x8(%ebp)
80107ee5:	e8 02 f8 ff ff       	call   801076ec <walkpgdir>
80107eea:	83 c4 10             	add    $0x10,%esp
80107eed:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ef0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ef4:	75 0d                	jne    80107f03 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
80107ef6:	83 ec 0c             	sub    $0xc,%esp
80107ef9:	68 2e ab 10 80       	push   $0x8010ab2e
80107efe:	e8 a6 86 ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
80107f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f06:	8b 00                	mov    (%eax),%eax
80107f08:	83 e0 01             	and    $0x1,%eax
80107f0b:	85 c0                	test   %eax,%eax
80107f0d:	75 0d                	jne    80107f1c <copyuvm+0x6d>
      panic("copyuvm: page not present");
80107f0f:	83 ec 0c             	sub    $0xc,%esp
80107f12:	68 48 ab 10 80       	push   $0x8010ab48
80107f17:	e8 8d 86 ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
80107f1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f1f:	8b 00                	mov    (%eax),%eax
80107f21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f26:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f2c:	8b 00                	mov    (%eax),%eax
80107f2e:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107f36:	e8 4f ad ff ff       	call   80102c8a <kalloc>
80107f3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107f3e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107f42:	74 5d                	je     80107fa1 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107f44:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107f47:	05 00 00 00 80       	add    $0x80000000,%eax
80107f4c:	83 ec 04             	sub    $0x4,%esp
80107f4f:	68 00 10 00 00       	push   $0x1000
80107f54:	50                   	push   %eax
80107f55:	ff 75 e0             	push   -0x20(%ebp)
80107f58:	e8 df cf ff ff       	call   80104f3c <memmove>
80107f5d:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107f60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107f63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107f66:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6f:	83 ec 0c             	sub    $0xc,%esp
80107f72:	52                   	push   %edx
80107f73:	51                   	push   %ecx
80107f74:	68 00 10 00 00       	push   $0x1000
80107f79:	50                   	push   %eax
80107f7a:	ff 75 f0             	push   -0x10(%ebp)
80107f7d:	e8 00 f8 ff ff       	call   80107782 <mappages>
80107f82:	83 c4 20             	add    $0x20,%esp
80107f85:	85 c0                	test   %eax,%eax
80107f87:	78 1b                	js     80107fa4 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107f89:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f93:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107f96:	0f 82 3d ff ff ff    	jb     80107ed9 <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9f:	eb 17                	jmp    80107fb8 <copyuvm+0x109>
      goto bad;
80107fa1:	90                   	nop
80107fa2:	eb 01                	jmp    80107fa5 <copyuvm+0xf6>
      goto bad;
80107fa4:	90                   	nop

bad:
  freevm(d);
80107fa5:	83 ec 0c             	sub    $0xc,%esp
80107fa8:	ff 75 f0             	push   -0x10(%ebp)
80107fab:	e8 25 fe ff ff       	call   80107dd5 <freevm>
80107fb0:	83 c4 10             	add    $0x10,%esp
  return 0;
80107fb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fb8:	c9                   	leave
80107fb9:	c3                   	ret

80107fba <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107fba:	55                   	push   %ebp
80107fbb:	89 e5                	mov    %esp,%ebp
80107fbd:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107fc0:	83 ec 04             	sub    $0x4,%esp
80107fc3:	6a 00                	push   $0x0
80107fc5:	ff 75 0c             	push   0xc(%ebp)
80107fc8:	ff 75 08             	push   0x8(%ebp)
80107fcb:	e8 1c f7 ff ff       	call   801076ec <walkpgdir>
80107fd0:	83 c4 10             	add    $0x10,%esp
80107fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	8b 00                	mov    (%eax),%eax
80107fdb:	83 e0 01             	and    $0x1,%eax
80107fde:	85 c0                	test   %eax,%eax
80107fe0:	75 07                	jne    80107fe9 <uva2ka+0x2f>
    return 0;
80107fe2:	b8 00 00 00 00       	mov    $0x0,%eax
80107fe7:	eb 22                	jmp    8010800b <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fec:	8b 00                	mov    (%eax),%eax
80107fee:	83 e0 04             	and    $0x4,%eax
80107ff1:	85 c0                	test   %eax,%eax
80107ff3:	75 07                	jne    80107ffc <uva2ka+0x42>
    return 0;
80107ff5:	b8 00 00 00 00       	mov    $0x0,%eax
80107ffa:	eb 0f                	jmp    8010800b <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fff:	8b 00                	mov    (%eax),%eax
80108001:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108006:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010800b:	c9                   	leave
8010800c:	c3                   	ret

8010800d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010800d:	55                   	push   %ebp
8010800e:	89 e5                	mov    %esp,%ebp
80108010:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108013:	8b 45 10             	mov    0x10(%ebp),%eax
80108016:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108019:	eb 7f                	jmp    8010809a <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010801b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010801e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108023:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108026:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108029:	83 ec 08             	sub    $0x8,%esp
8010802c:	50                   	push   %eax
8010802d:	ff 75 08             	push   0x8(%ebp)
80108030:	e8 85 ff ff ff       	call   80107fba <uva2ka>
80108035:	83 c4 10             	add    $0x10,%esp
80108038:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010803b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010803f:	75 07                	jne    80108048 <copyout+0x3b>
      return -1;
80108041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108046:	eb 61                	jmp    801080a9 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108048:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010804b:	2b 45 0c             	sub    0xc(%ebp),%eax
8010804e:	05 00 10 00 00       	add    $0x1000,%eax
80108053:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108059:	39 45 14             	cmp    %eax,0x14(%ebp)
8010805c:	73 06                	jae    80108064 <copyout+0x57>
      n = len;
8010805e:	8b 45 14             	mov    0x14(%ebp),%eax
80108061:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108064:	8b 45 0c             	mov    0xc(%ebp),%eax
80108067:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010806a:	89 c2                	mov    %eax,%edx
8010806c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010806f:	01 d0                	add    %edx,%eax
80108071:	83 ec 04             	sub    $0x4,%esp
80108074:	ff 75 f0             	push   -0x10(%ebp)
80108077:	ff 75 f4             	push   -0xc(%ebp)
8010807a:	50                   	push   %eax
8010807b:	e8 bc ce ff ff       	call   80104f3c <memmove>
80108080:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108086:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108089:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010808c:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010808f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108092:	05 00 10 00 00       	add    $0x1000,%eax
80108097:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
8010809a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010809e:	0f 85 77 ff ff ff    	jne    8010801b <copyout+0xe>
  }
  return 0;
801080a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080a9:	c9                   	leave
801080aa:	c3                   	ret

801080ab <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
801080ab:	55                   	push   %ebp
801080ac:	89 e5                	mov    %esp,%ebp
801080ae:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801080b1:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
801080b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801080bb:	8b 40 08             	mov    0x8(%eax),%eax
801080be:	05 00 00 00 80       	add    $0x80000000,%eax
801080c3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
801080c6:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
801080cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d0:	8b 40 24             	mov    0x24(%eax),%eax
801080d3:	a3 40 71 11 80       	mov    %eax,0x80117140
  ncpu = 0;
801080d8:	c7 05 80 9d 11 80 00 	movl   $0x0,0x80119d80
801080df:	00 00 00 

  while(i<madt->len){
801080e2:	e9 bd 00 00 00       	jmp    801081a4 <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
801080e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801080ed:	01 d0                	add    %edx,%eax
801080ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
801080f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080f5:	0f b6 00             	movzbl (%eax),%eax
801080f8:	0f b6 c0             	movzbl %al,%eax
801080fb:	83 f8 05             	cmp    $0x5,%eax
801080fe:	0f 87 a0 00 00 00    	ja     801081a4 <mpinit_uefi+0xf9>
80108104:	8b 04 85 64 ab 10 80 	mov    -0x7fef549c(,%eax,4),%eax
8010810b:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
8010810d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108110:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80108113:	a1 80 9d 11 80       	mov    0x80119d80,%eax
80108118:	83 f8 03             	cmp    $0x3,%eax
8010811b:	7f 28                	jg     80108145 <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
8010811d:	8b 15 80 9d 11 80    	mov    0x80119d80,%edx
80108123:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108126:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010812a:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80108130:	81 c2 c0 9a 11 80    	add    $0x80119ac0,%edx
80108136:	88 02                	mov    %al,(%edx)
          ncpu++;
80108138:	a1 80 9d 11 80       	mov    0x80119d80,%eax
8010813d:	83 c0 01             	add    $0x1,%eax
80108140:	a3 80 9d 11 80       	mov    %eax,0x80119d80
        }
        i += lapic_entry->record_len;
80108145:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108148:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010814c:	0f b6 c0             	movzbl %al,%eax
8010814f:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108152:	eb 50                	jmp    801081a4 <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80108154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108157:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
8010815a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010815d:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80108161:	a2 84 9d 11 80       	mov    %al,0x80119d84
        i += ioapic->record_len;
80108166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108169:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010816d:	0f b6 c0             	movzbl %al,%eax
80108170:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108173:	eb 2f                	jmp    801081a4 <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80108175:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108178:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
8010817b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010817e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108182:	0f b6 c0             	movzbl %al,%eax
80108185:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80108188:	eb 1a                	jmp    801081a4 <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
8010818a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010818d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80108190:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108193:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108197:	0f b6 c0             	movzbl %al,%eax
8010819a:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
8010819d:	eb 05                	jmp    801081a4 <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
8010819f:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
801081a3:	90                   	nop
  while(i<madt->len){
801081a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a7:	8b 40 04             	mov    0x4(%eax),%eax
801081aa:	39 45 fc             	cmp    %eax,-0x4(%ebp)
801081ad:	0f 82 34 ff ff ff    	jb     801080e7 <mpinit_uefi+0x3c>
    }
  }

}
801081b3:	90                   	nop
801081b4:	90                   	nop
801081b5:	c9                   	leave
801081b6:	c3                   	ret

801081b7 <inb>:
{
801081b7:	55                   	push   %ebp
801081b8:	89 e5                	mov    %esp,%ebp
801081ba:	83 ec 14             	sub    $0x14,%esp
801081bd:	8b 45 08             	mov    0x8(%ebp),%eax
801081c0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801081c4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801081c8:	89 c2                	mov    %eax,%edx
801081ca:	ec                   	in     (%dx),%al
801081cb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801081ce:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801081d2:	c9                   	leave
801081d3:	c3                   	ret

801081d4 <outb>:
{
801081d4:	55                   	push   %ebp
801081d5:	89 e5                	mov    %esp,%ebp
801081d7:	83 ec 08             	sub    $0x8,%esp
801081da:	8b 55 08             	mov    0x8(%ebp),%edx
801081dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801081e0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801081e4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801081e7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801081eb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801081ef:	ee                   	out    %al,(%dx)
}
801081f0:	90                   	nop
801081f1:	c9                   	leave
801081f2:	c3                   	ret

801081f3 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
801081f3:	55                   	push   %ebp
801081f4:	89 e5                	mov    %esp,%ebp
801081f6:	83 ec 28             	sub    $0x28,%esp
801081f9:	8b 45 08             	mov    0x8(%ebp),%eax
801081fc:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
801081ff:	6a 00                	push   $0x0
80108201:	68 fa 03 00 00       	push   $0x3fa
80108206:	e8 c9 ff ff ff       	call   801081d4 <outb>
8010820b:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010820e:	68 80 00 00 00       	push   $0x80
80108213:	68 fb 03 00 00       	push   $0x3fb
80108218:	e8 b7 ff ff ff       	call   801081d4 <outb>
8010821d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80108220:	6a 0c                	push   $0xc
80108222:	68 f8 03 00 00       	push   $0x3f8
80108227:	e8 a8 ff ff ff       	call   801081d4 <outb>
8010822c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
8010822f:	6a 00                	push   $0x0
80108231:	68 f9 03 00 00       	push   $0x3f9
80108236:	e8 99 ff ff ff       	call   801081d4 <outb>
8010823b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010823e:	6a 03                	push   $0x3
80108240:	68 fb 03 00 00       	push   $0x3fb
80108245:	e8 8a ff ff ff       	call   801081d4 <outb>
8010824a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010824d:	6a 00                	push   $0x0
8010824f:	68 fc 03 00 00       	push   $0x3fc
80108254:	e8 7b ff ff ff       	call   801081d4 <outb>
80108259:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
8010825c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108263:	eb 11                	jmp    80108276 <uart_debug+0x83>
80108265:	83 ec 0c             	sub    $0xc,%esp
80108268:	6a 0a                	push   $0xa
8010826a:	e8 ac ad ff ff       	call   8010301b <microdelay>
8010826f:	83 c4 10             	add    $0x10,%esp
80108272:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108276:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010827a:	7f 1a                	jg     80108296 <uart_debug+0xa3>
8010827c:	83 ec 0c             	sub    $0xc,%esp
8010827f:	68 fd 03 00 00       	push   $0x3fd
80108284:	e8 2e ff ff ff       	call   801081b7 <inb>
80108289:	83 c4 10             	add    $0x10,%esp
8010828c:	0f b6 c0             	movzbl %al,%eax
8010828f:	83 e0 20             	and    $0x20,%eax
80108292:	85 c0                	test   %eax,%eax
80108294:	74 cf                	je     80108265 <uart_debug+0x72>
  outb(COM1+0, p);
80108296:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
8010829a:	0f b6 c0             	movzbl %al,%eax
8010829d:	83 ec 08             	sub    $0x8,%esp
801082a0:	50                   	push   %eax
801082a1:	68 f8 03 00 00       	push   $0x3f8
801082a6:	e8 29 ff ff ff       	call   801081d4 <outb>
801082ab:	83 c4 10             	add    $0x10,%esp
}
801082ae:	90                   	nop
801082af:	c9                   	leave
801082b0:	c3                   	ret

801082b1 <uart_debugs>:

void uart_debugs(char *p){
801082b1:	55                   	push   %ebp
801082b2:	89 e5                	mov    %esp,%ebp
801082b4:	83 ec 08             	sub    $0x8,%esp
  while(*p){
801082b7:	eb 1b                	jmp    801082d4 <uart_debugs+0x23>
    uart_debug(*p++);
801082b9:	8b 45 08             	mov    0x8(%ebp),%eax
801082bc:	8d 50 01             	lea    0x1(%eax),%edx
801082bf:	89 55 08             	mov    %edx,0x8(%ebp)
801082c2:	0f b6 00             	movzbl (%eax),%eax
801082c5:	0f be c0             	movsbl %al,%eax
801082c8:	83 ec 0c             	sub    $0xc,%esp
801082cb:	50                   	push   %eax
801082cc:	e8 22 ff ff ff       	call   801081f3 <uart_debug>
801082d1:	83 c4 10             	add    $0x10,%esp
  while(*p){
801082d4:	8b 45 08             	mov    0x8(%ebp),%eax
801082d7:	0f b6 00             	movzbl (%eax),%eax
801082da:	84 c0                	test   %al,%al
801082dc:	75 db                	jne    801082b9 <uart_debugs+0x8>
  }
}
801082de:	90                   	nop
801082df:	90                   	nop
801082e0:	c9                   	leave
801082e1:	c3                   	ret

801082e2 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
801082e2:	55                   	push   %ebp
801082e3:	89 e5                	mov    %esp,%ebp
801082e5:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
801082e8:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
801082ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801082f2:	8b 50 14             	mov    0x14(%eax),%edx
801082f5:	8b 40 10             	mov    0x10(%eax),%eax
801082f8:	a3 88 9d 11 80       	mov    %eax,0x80119d88
  gpu.vram_size = boot_param->graphic_config.frame_size;
801082fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108300:	8b 50 1c             	mov    0x1c(%eax),%edx
80108303:	8b 40 18             	mov    0x18(%eax),%eax
80108306:	a3 90 9d 11 80       	mov    %eax,0x80119d90
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
8010830b:	a1 90 9d 11 80       	mov    0x80119d90,%eax
80108310:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80108315:	29 c2                	sub    %eax,%edx
80108317:	89 15 8c 9d 11 80    	mov    %edx,0x80119d8c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
8010831d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108320:	8b 50 24             	mov    0x24(%eax),%edx
80108323:	8b 40 20             	mov    0x20(%eax),%eax
80108326:	a3 94 9d 11 80       	mov    %eax,0x80119d94
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
8010832b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010832e:	8b 50 2c             	mov    0x2c(%eax),%edx
80108331:	8b 40 28             	mov    0x28(%eax),%eax
80108334:	a3 98 9d 11 80       	mov    %eax,0x80119d98
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80108339:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010833c:	8b 50 34             	mov    0x34(%eax),%edx
8010833f:	8b 40 30             	mov    0x30(%eax),%eax
80108342:	a3 9c 9d 11 80       	mov    %eax,0x80119d9c
}
80108347:	90                   	nop
80108348:	c9                   	leave
80108349:	c3                   	ret

8010834a <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
8010834a:	55                   	push   %ebp
8010834b:	89 e5                	mov    %esp,%ebp
8010834d:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80108350:	8b 15 9c 9d 11 80    	mov    0x80119d9c,%edx
80108356:	8b 45 0c             	mov    0xc(%ebp),%eax
80108359:	0f af d0             	imul   %eax,%edx
8010835c:	8b 45 08             	mov    0x8(%ebp),%eax
8010835f:	01 d0                	add    %edx,%eax
80108361:	c1 e0 02             	shl    $0x2,%eax
80108364:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80108367:	8b 15 8c 9d 11 80    	mov    0x80119d8c,%edx
8010836d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108370:	01 d0                	add    %edx,%eax
80108372:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80108375:	8b 45 10             	mov    0x10(%ebp),%eax
80108378:	0f b6 10             	movzbl (%eax),%edx
8010837b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010837e:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80108380:	8b 45 10             	mov    0x10(%ebp),%eax
80108383:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80108387:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010838a:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
8010838d:	8b 45 10             	mov    0x10(%ebp),%eax
80108390:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80108394:	8b 45 f8             	mov    -0x8(%ebp),%eax
80108397:	88 50 02             	mov    %dl,0x2(%eax)
}
8010839a:	90                   	nop
8010839b:	c9                   	leave
8010839c:	c3                   	ret

8010839d <graphic_scroll_up>:

void graphic_scroll_up(int height){
8010839d:	55                   	push   %ebp
8010839e:	89 e5                	mov    %esp,%ebp
801083a0:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
801083a3:	8b 15 9c 9d 11 80    	mov    0x80119d9c,%edx
801083a9:	8b 45 08             	mov    0x8(%ebp),%eax
801083ac:	0f af c2             	imul   %edx,%eax
801083af:	c1 e0 02             	shl    $0x2,%eax
801083b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
801083b5:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
801083bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083be:	29 c2                	sub    %eax,%edx
801083c0:	8b 0d 8c 9d 11 80    	mov    0x80119d8c,%ecx
801083c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c9:	01 c8                	add    %ecx,%eax
801083cb:	89 c1                	mov    %eax,%ecx
801083cd:	a1 8c 9d 11 80       	mov    0x80119d8c,%eax
801083d2:	83 ec 04             	sub    $0x4,%esp
801083d5:	52                   	push   %edx
801083d6:	51                   	push   %ecx
801083d7:	50                   	push   %eax
801083d8:	e8 5f cb ff ff       	call   80104f3c <memmove>
801083dd:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
801083e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e3:	8b 0d 8c 9d 11 80    	mov    0x80119d8c,%ecx
801083e9:	8b 15 90 9d 11 80    	mov    0x80119d90,%edx
801083ef:	01 d1                	add    %edx,%ecx
801083f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801083f4:	29 d1                	sub    %edx,%ecx
801083f6:	89 ca                	mov    %ecx,%edx
801083f8:	83 ec 04             	sub    $0x4,%esp
801083fb:	50                   	push   %eax
801083fc:	6a 00                	push   $0x0
801083fe:	52                   	push   %edx
801083ff:	e8 79 ca ff ff       	call   80104e7d <memset>
80108404:	83 c4 10             	add    $0x10,%esp
}
80108407:	90                   	nop
80108408:	c9                   	leave
80108409:	c3                   	ret

8010840a <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
8010840a:	55                   	push   %ebp
8010840b:	89 e5                	mov    %esp,%ebp
8010840d:	53                   	push   %ebx
8010840e:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80108411:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108418:	e9 b1 00 00 00       	jmp    801084ce <font_render+0xc4>
    for(int j=14;j>-1;j--){
8010841d:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108424:	e9 97 00 00 00       	jmp    801084c0 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108429:	8b 45 10             	mov    0x10(%ebp),%eax
8010842c:	83 e8 20             	sub    $0x20,%eax
8010842f:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108435:	01 d0                	add    %edx,%eax
80108437:	0f b7 84 00 80 ab 10 	movzwl -0x7fef5480(%eax,%eax,1),%eax
8010843e:	80 
8010843f:	0f b7 d0             	movzwl %ax,%edx
80108442:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108445:	bb 01 00 00 00       	mov    $0x1,%ebx
8010844a:	89 c1                	mov    %eax,%ecx
8010844c:	d3 e3                	shl    %cl,%ebx
8010844e:	89 d8                	mov    %ebx,%eax
80108450:	21 d0                	and    %edx,%eax
80108452:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108458:	ba 01 00 00 00       	mov    $0x1,%edx
8010845d:	89 c1                	mov    %eax,%ecx
8010845f:	d3 e2                	shl    %cl,%edx
80108461:	89 d0                	mov    %edx,%eax
80108463:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108466:	75 2b                	jne    80108493 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108468:	8b 55 0c             	mov    0xc(%ebp),%edx
8010846b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846e:	01 c2                	add    %eax,%edx
80108470:	b8 0e 00 00 00       	mov    $0xe,%eax
80108475:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108478:	89 c1                	mov    %eax,%ecx
8010847a:	8b 45 08             	mov    0x8(%ebp),%eax
8010847d:	01 c8                	add    %ecx,%eax
8010847f:	83 ec 04             	sub    $0x4,%esp
80108482:	68 e0 f4 10 80       	push   $0x8010f4e0
80108487:	52                   	push   %edx
80108488:	50                   	push   %eax
80108489:	e8 bc fe ff ff       	call   8010834a <graphic_draw_pixel>
8010848e:	83 c4 10             	add    $0x10,%esp
80108491:	eb 29                	jmp    801084bc <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108493:	8b 55 0c             	mov    0xc(%ebp),%edx
80108496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108499:	01 c2                	add    %eax,%edx
8010849b:	b8 0e 00 00 00       	mov    $0xe,%eax
801084a0:	2b 45 f0             	sub    -0x10(%ebp),%eax
801084a3:	89 c1                	mov    %eax,%ecx
801084a5:	8b 45 08             	mov    0x8(%ebp),%eax
801084a8:	01 c8                	add    %ecx,%eax
801084aa:	83 ec 04             	sub    $0x4,%esp
801084ad:	68 a0 9d 11 80       	push   $0x80119da0
801084b2:	52                   	push   %edx
801084b3:	50                   	push   %eax
801084b4:	e8 91 fe ff ff       	call   8010834a <graphic_draw_pixel>
801084b9:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
801084bc:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
801084c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084c4:	0f 89 5f ff ff ff    	jns    80108429 <font_render+0x1f>
  for(int i=0;i<30;i++){
801084ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084ce:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801084d2:	0f 8e 45 ff ff ff    	jle    8010841d <font_render+0x13>
      }
    }
  }
}
801084d8:	90                   	nop
801084d9:	90                   	nop
801084da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084dd:	c9                   	leave
801084de:	c3                   	ret

801084df <font_render_string>:

void font_render_string(char *string,int row){
801084df:	55                   	push   %ebp
801084e0:	89 e5                	mov    %esp,%ebp
801084e2:	53                   	push   %ebx
801084e3:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801084e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801084ed:	eb 33                	jmp    80108522 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801084ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801084f2:	8b 45 08             	mov    0x8(%ebp),%eax
801084f5:	01 d0                	add    %edx,%eax
801084f7:	0f b6 00             	movzbl (%eax),%eax
801084fa:	0f be d8             	movsbl %al,%ebx
801084fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108500:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80108503:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108506:	89 d0                	mov    %edx,%eax
80108508:	c1 e0 04             	shl    $0x4,%eax
8010850b:	29 d0                	sub    %edx,%eax
8010850d:	83 c0 02             	add    $0x2,%eax
80108510:	83 ec 04             	sub    $0x4,%esp
80108513:	53                   	push   %ebx
80108514:	51                   	push   %ecx
80108515:	50                   	push   %eax
80108516:	e8 ef fe ff ff       	call   8010840a <font_render>
8010851b:	83 c4 10             	add    $0x10,%esp
    i++;
8010851e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108522:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108525:	8b 45 08             	mov    0x8(%ebp),%eax
80108528:	01 d0                	add    %edx,%eax
8010852a:	0f b6 00             	movzbl (%eax),%eax
8010852d:	84 c0                	test   %al,%al
8010852f:	74 06                	je     80108537 <font_render_string+0x58>
80108531:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108535:	7e b8                	jle    801084ef <font_render_string+0x10>
  }
}
80108537:	90                   	nop
80108538:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010853b:	c9                   	leave
8010853c:	c3                   	ret

8010853d <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010853d:	55                   	push   %ebp
8010853e:	89 e5                	mov    %esp,%ebp
80108540:	53                   	push   %ebx
80108541:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108544:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010854b:	eb 6b                	jmp    801085b8 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010854d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108554:	eb 58                	jmp    801085ae <pci_init+0x71>
      for(int k=0;k<8;k++){
80108556:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010855d:	eb 45                	jmp    801085a4 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010855f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108562:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108568:	83 ec 0c             	sub    $0xc,%esp
8010856b:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010856e:	53                   	push   %ebx
8010856f:	6a 00                	push   $0x0
80108571:	51                   	push   %ecx
80108572:	52                   	push   %edx
80108573:	50                   	push   %eax
80108574:	e8 b0 00 00 00       	call   80108629 <pci_access_config>
80108579:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010857c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010857f:	0f b7 c0             	movzwl %ax,%eax
80108582:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108587:	74 17                	je     801085a0 <pci_init+0x63>
        pci_init_device(i,j,k);
80108589:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010858c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108592:	83 ec 04             	sub    $0x4,%esp
80108595:	51                   	push   %ecx
80108596:	52                   	push   %edx
80108597:	50                   	push   %eax
80108598:	e8 37 01 00 00       	call   801086d4 <pci_init_device>
8010859d:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
801085a0:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801085a4:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801085a8:	7e b5                	jle    8010855f <pci_init+0x22>
    for(int j=0;j<32;j++){
801085aa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801085ae:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
801085b2:	7e a2                	jle    80108556 <pci_init+0x19>
  for(int i=0;i<256;i++){
801085b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085b8:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801085bf:	7e 8c                	jle    8010854d <pci_init+0x10>
      }
      }
    }
  }
}
801085c1:	90                   	nop
801085c2:	90                   	nop
801085c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085c6:	c9                   	leave
801085c7:	c3                   	ret

801085c8 <pci_write_config>:

void pci_write_config(uint config){
801085c8:	55                   	push   %ebp
801085c9:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801085cb:	8b 45 08             	mov    0x8(%ebp),%eax
801085ce:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801085d3:	89 c0                	mov    %eax,%eax
801085d5:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085d6:	90                   	nop
801085d7:	5d                   	pop    %ebp
801085d8:	c3                   	ret

801085d9 <pci_write_data>:

void pci_write_data(uint config){
801085d9:	55                   	push   %ebp
801085da:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801085dc:	8b 45 08             	mov    0x8(%ebp),%eax
801085df:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085e4:	89 c0                	mov    %eax,%eax
801085e6:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801085e7:	90                   	nop
801085e8:	5d                   	pop    %ebp
801085e9:	c3                   	ret

801085ea <pci_read_config>:
uint pci_read_config(){
801085ea:	55                   	push   %ebp
801085eb:	89 e5                	mov    %esp,%ebp
801085ed:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801085f0:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801085f5:	ed                   	in     (%dx),%eax
801085f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801085f9:	83 ec 0c             	sub    $0xc,%esp
801085fc:	68 c8 00 00 00       	push   $0xc8
80108601:	e8 15 aa ff ff       	call   8010301b <microdelay>
80108606:	83 c4 10             	add    $0x10,%esp
  return data;
80108609:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010860c:	c9                   	leave
8010860d:	c3                   	ret

8010860e <pci_test>:


void pci_test(){
8010860e:	55                   	push   %ebp
8010860f:	89 e5                	mov    %esp,%ebp
80108611:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
80108614:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
8010861b:	ff 75 fc             	push   -0x4(%ebp)
8010861e:	e8 a5 ff ff ff       	call   801085c8 <pci_write_config>
80108623:	83 c4 04             	add    $0x4,%esp
}
80108626:	90                   	nop
80108627:	c9                   	leave
80108628:	c3                   	ret

80108629 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108629:	55                   	push   %ebp
8010862a:	89 e5                	mov    %esp,%ebp
8010862c:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010862f:	8b 45 08             	mov    0x8(%ebp),%eax
80108632:	c1 e0 10             	shl    $0x10,%eax
80108635:	25 00 00 ff 00       	and    $0xff0000,%eax
8010863a:	89 c2                	mov    %eax,%edx
8010863c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010863f:	c1 e0 0b             	shl    $0xb,%eax
80108642:	0f b7 c0             	movzwl %ax,%eax
80108645:	09 c2                	or     %eax,%edx
80108647:	8b 45 10             	mov    0x10(%ebp),%eax
8010864a:	c1 e0 08             	shl    $0x8,%eax
8010864d:	25 00 07 00 00       	and    $0x700,%eax
80108652:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108654:	8b 45 14             	mov    0x14(%ebp),%eax
80108657:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010865c:	09 d0                	or     %edx,%eax
8010865e:	0d 00 00 00 80       	or     $0x80000000,%eax
80108663:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108666:	ff 75 f4             	push   -0xc(%ebp)
80108669:	e8 5a ff ff ff       	call   801085c8 <pci_write_config>
8010866e:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108671:	e8 74 ff ff ff       	call   801085ea <pci_read_config>
80108676:	8b 55 18             	mov    0x18(%ebp),%edx
80108679:	89 02                	mov    %eax,(%edx)
}
8010867b:	90                   	nop
8010867c:	c9                   	leave
8010867d:	c3                   	ret

8010867e <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010867e:	55                   	push   %ebp
8010867f:	89 e5                	mov    %esp,%ebp
80108681:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108684:	8b 45 08             	mov    0x8(%ebp),%eax
80108687:	c1 e0 10             	shl    $0x10,%eax
8010868a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010868f:	89 c2                	mov    %eax,%edx
80108691:	8b 45 0c             	mov    0xc(%ebp),%eax
80108694:	c1 e0 0b             	shl    $0xb,%eax
80108697:	0f b7 c0             	movzwl %ax,%eax
8010869a:	09 c2                	or     %eax,%edx
8010869c:	8b 45 10             	mov    0x10(%ebp),%eax
8010869f:	c1 e0 08             	shl    $0x8,%eax
801086a2:	25 00 07 00 00       	and    $0x700,%eax
801086a7:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
801086a9:	8b 45 14             	mov    0x14(%ebp),%eax
801086ac:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
801086b1:	09 d0                	or     %edx,%eax
801086b3:	0d 00 00 00 80       	or     $0x80000000,%eax
801086b8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
801086bb:	ff 75 fc             	push   -0x4(%ebp)
801086be:	e8 05 ff ff ff       	call   801085c8 <pci_write_config>
801086c3:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801086c6:	ff 75 18             	push   0x18(%ebp)
801086c9:	e8 0b ff ff ff       	call   801085d9 <pci_write_data>
801086ce:	83 c4 04             	add    $0x4,%esp
}
801086d1:	90                   	nop
801086d2:	c9                   	leave
801086d3:	c3                   	ret

801086d4 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801086d4:	55                   	push   %ebp
801086d5:	89 e5                	mov    %esp,%ebp
801086d7:	53                   	push   %ebx
801086d8:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801086db:	8b 45 08             	mov    0x8(%ebp),%eax
801086de:	a2 a4 9d 11 80       	mov    %al,0x80119da4
  dev.device_num = device_num;
801086e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801086e6:	a2 a5 9d 11 80       	mov    %al,0x80119da5
  dev.function_num = function_num;
801086eb:	8b 45 10             	mov    0x10(%ebp),%eax
801086ee:	a2 a6 9d 11 80       	mov    %al,0x80119da6
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801086f3:	ff 75 10             	push   0x10(%ebp)
801086f6:	ff 75 0c             	push   0xc(%ebp)
801086f9:	ff 75 08             	push   0x8(%ebp)
801086fc:	68 c4 c1 10 80       	push   $0x8010c1c4
80108701:	e8 ee 7c ff ff       	call   801003f4 <cprintf>
80108706:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
80108709:	83 ec 0c             	sub    $0xc,%esp
8010870c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010870f:	50                   	push   %eax
80108710:	6a 00                	push   $0x0
80108712:	ff 75 10             	push   0x10(%ebp)
80108715:	ff 75 0c             	push   0xc(%ebp)
80108718:	ff 75 08             	push   0x8(%ebp)
8010871b:	e8 09 ff ff ff       	call   80108629 <pci_access_config>
80108720:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108723:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108726:	c1 e8 10             	shr    $0x10,%eax
80108729:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010872c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010872f:	25 ff ff 00 00       	and    $0xffff,%eax
80108734:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873a:	a3 a8 9d 11 80       	mov    %eax,0x80119da8
  dev.vendor_id = vendor_id;
8010873f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108742:	a3 ac 9d 11 80       	mov    %eax,0x80119dac
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108747:	83 ec 04             	sub    $0x4,%esp
8010874a:	ff 75 f0             	push   -0x10(%ebp)
8010874d:	ff 75 f4             	push   -0xc(%ebp)
80108750:	68 f8 c1 10 80       	push   $0x8010c1f8
80108755:	e8 9a 7c ff ff       	call   801003f4 <cprintf>
8010875a:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010875d:	83 ec 0c             	sub    $0xc,%esp
80108760:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108763:	50                   	push   %eax
80108764:	6a 08                	push   $0x8
80108766:	ff 75 10             	push   0x10(%ebp)
80108769:	ff 75 0c             	push   0xc(%ebp)
8010876c:	ff 75 08             	push   0x8(%ebp)
8010876f:	e8 b5 fe ff ff       	call   80108629 <pci_access_config>
80108774:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108777:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010877a:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010877d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108780:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108783:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108786:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108789:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010878c:	0f b6 c0             	movzbl %al,%eax
8010878f:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108792:	c1 eb 18             	shr    $0x18,%ebx
80108795:	83 ec 0c             	sub    $0xc,%esp
80108798:	51                   	push   %ecx
80108799:	52                   	push   %edx
8010879a:	50                   	push   %eax
8010879b:	53                   	push   %ebx
8010879c:	68 1c c2 10 80       	push   $0x8010c21c
801087a1:	e8 4e 7c ff ff       	call   801003f4 <cprintf>
801087a6:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
801087a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ac:	c1 e8 18             	shr    $0x18,%eax
801087af:	a2 b0 9d 11 80       	mov    %al,0x80119db0
  dev.sub_class = (data>>16)&0xFF;
801087b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087b7:	c1 e8 10             	shr    $0x10,%eax
801087ba:	a2 b1 9d 11 80       	mov    %al,0x80119db1
  dev.interface = (data>>8)&0xFF;
801087bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c2:	c1 e8 08             	shr    $0x8,%eax
801087c5:	a2 b2 9d 11 80       	mov    %al,0x80119db2
  dev.revision_id = data&0xFF;
801087ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087cd:	a2 b3 9d 11 80       	mov    %al,0x80119db3
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801087d2:	83 ec 0c             	sub    $0xc,%esp
801087d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087d8:	50                   	push   %eax
801087d9:	6a 10                	push   $0x10
801087db:	ff 75 10             	push   0x10(%ebp)
801087de:	ff 75 0c             	push   0xc(%ebp)
801087e1:	ff 75 08             	push   0x8(%ebp)
801087e4:	e8 40 fe ff ff       	call   80108629 <pci_access_config>
801087e9:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801087ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087ef:	a3 b4 9d 11 80       	mov    %eax,0x80119db4
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801087f4:	83 ec 0c             	sub    $0xc,%esp
801087f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801087fa:	50                   	push   %eax
801087fb:	6a 14                	push   $0x14
801087fd:	ff 75 10             	push   0x10(%ebp)
80108800:	ff 75 0c             	push   0xc(%ebp)
80108803:	ff 75 08             	push   0x8(%ebp)
80108806:	e8 1e fe ff ff       	call   80108629 <pci_access_config>
8010880b:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
8010880e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108811:	a3 b8 9d 11 80       	mov    %eax,0x80119db8
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
80108816:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
8010881d:	75 5a                	jne    80108879 <pci_init_device+0x1a5>
8010881f:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108826:	75 51                	jne    80108879 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108828:	83 ec 0c             	sub    $0xc,%esp
8010882b:	68 61 c2 10 80       	push   $0x8010c261
80108830:	e8 bf 7b ff ff       	call   801003f4 <cprintf>
80108835:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108838:	83 ec 0c             	sub    $0xc,%esp
8010883b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010883e:	50                   	push   %eax
8010883f:	68 f0 00 00 00       	push   $0xf0
80108844:	ff 75 10             	push   0x10(%ebp)
80108847:	ff 75 0c             	push   0xc(%ebp)
8010884a:	ff 75 08             	push   0x8(%ebp)
8010884d:	e8 d7 fd ff ff       	call   80108629 <pci_access_config>
80108852:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108855:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108858:	83 ec 08             	sub    $0x8,%esp
8010885b:	50                   	push   %eax
8010885c:	68 7b c2 10 80       	push   $0x8010c27b
80108861:	e8 8e 7b ff ff       	call   801003f4 <cprintf>
80108866:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108869:	83 ec 0c             	sub    $0xc,%esp
8010886c:	68 a4 9d 11 80       	push   $0x80119da4
80108871:	e8 09 00 00 00       	call   8010887f <i8254_init>
80108876:	83 c4 10             	add    $0x10,%esp
  }
}
80108879:	90                   	nop
8010887a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010887d:	c9                   	leave
8010887e:	c3                   	ret

8010887f <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010887f:	55                   	push   %ebp
80108880:	89 e5                	mov    %esp,%ebp
80108882:	53                   	push   %ebx
80108883:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108886:	8b 45 08             	mov    0x8(%ebp),%eax
80108889:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010888d:	0f b6 c8             	movzbl %al,%ecx
80108890:	8b 45 08             	mov    0x8(%ebp),%eax
80108893:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108897:	0f b6 d0             	movzbl %al,%edx
8010889a:	8b 45 08             	mov    0x8(%ebp),%eax
8010889d:	0f b6 00             	movzbl (%eax),%eax
801088a0:	0f b6 c0             	movzbl %al,%eax
801088a3:	83 ec 0c             	sub    $0xc,%esp
801088a6:	8d 5d ec             	lea    -0x14(%ebp),%ebx
801088a9:	53                   	push   %ebx
801088aa:	6a 04                	push   $0x4
801088ac:	51                   	push   %ecx
801088ad:	52                   	push   %edx
801088ae:	50                   	push   %eax
801088af:	e8 75 fd ff ff       	call   80108629 <pci_access_config>
801088b4:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
801088b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ba:	83 c8 04             	or     $0x4,%eax
801088bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801088c0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801088c3:	8b 45 08             	mov    0x8(%ebp),%eax
801088c6:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801088ca:	0f b6 c8             	movzbl %al,%ecx
801088cd:	8b 45 08             	mov    0x8(%ebp),%eax
801088d0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801088d4:	0f b6 d0             	movzbl %al,%edx
801088d7:	8b 45 08             	mov    0x8(%ebp),%eax
801088da:	0f b6 00             	movzbl (%eax),%eax
801088dd:	0f b6 c0             	movzbl %al,%eax
801088e0:	83 ec 0c             	sub    $0xc,%esp
801088e3:	53                   	push   %ebx
801088e4:	6a 04                	push   $0x4
801088e6:	51                   	push   %ecx
801088e7:	52                   	push   %edx
801088e8:	50                   	push   %eax
801088e9:	e8 90 fd ff ff       	call   8010867e <pci_write_config_register>
801088ee:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801088f1:	8b 45 08             	mov    0x8(%ebp),%eax
801088f4:	8b 40 10             	mov    0x10(%eax),%eax
801088f7:	05 00 00 00 40       	add    $0x40000000,%eax
801088fc:	a3 bc 9d 11 80       	mov    %eax,0x80119dbc
  uint *ctrl = (uint *)base_addr;
80108901:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108906:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
80108909:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
8010890e:	05 d8 00 00 00       	add    $0xd8,%eax
80108913:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
80108916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108919:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
8010891f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108922:	8b 00                	mov    (%eax),%eax
80108924:	0d 00 00 00 04       	or     $0x4000000,%eax
80108929:	89 c2                	mov    %eax,%edx
8010892b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010892e:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108933:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893c:	8b 00                	mov    (%eax),%eax
8010893e:	83 c8 40             	or     $0x40,%eax
80108941:	89 c2                	mov    %eax,%edx
80108943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108946:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894b:	8b 10                	mov    (%eax),%edx
8010894d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108950:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108952:	83 ec 0c             	sub    $0xc,%esp
80108955:	68 90 c2 10 80       	push   $0x8010c290
8010895a:	e8 95 7a ff ff       	call   801003f4 <cprintf>
8010895f:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108962:	e8 23 a3 ff ff       	call   80102c8a <kalloc>
80108967:	a3 c8 9d 11 80       	mov    %eax,0x80119dc8
  *intr_addr = 0;
8010896c:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
80108971:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108977:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
8010897c:	83 ec 08             	sub    $0x8,%esp
8010897f:	50                   	push   %eax
80108980:	68 b2 c2 10 80       	push   $0x8010c2b2
80108985:	e8 6a 7a ff ff       	call   801003f4 <cprintf>
8010898a:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010898d:	e8 50 00 00 00       	call   801089e2 <i8254_init_recv>
  i8254_init_send();
80108992:	e8 69 03 00 00       	call   80108d00 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108997:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010899e:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
801089a1:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089a8:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
801089ab:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089b2:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
801089b5:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
801089bc:	0f b6 c0             	movzbl %al,%eax
801089bf:	83 ec 0c             	sub    $0xc,%esp
801089c2:	53                   	push   %ebx
801089c3:	51                   	push   %ecx
801089c4:	52                   	push   %edx
801089c5:	50                   	push   %eax
801089c6:	68 c0 c2 10 80       	push   $0x8010c2c0
801089cb:	e8 24 7a ff ff       	call   801003f4 <cprintf>
801089d0:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801089d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801089dc:	90                   	nop
801089dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089e0:	c9                   	leave
801089e1:	c3                   	ret

801089e2 <i8254_init_recv>:

void i8254_init_recv(){
801089e2:	55                   	push   %ebp
801089e3:	89 e5                	mov    %esp,%ebp
801089e5:	57                   	push   %edi
801089e6:	56                   	push   %esi
801089e7:	53                   	push   %ebx
801089e8:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801089eb:	83 ec 0c             	sub    $0xc,%esp
801089ee:	6a 00                	push   $0x0
801089f0:	e8 e8 04 00 00       	call   80108edd <i8254_read_eeprom>
801089f5:	83 c4 10             	add    $0x10,%esp
801089f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801089fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801089fe:	a2 c0 9d 11 80       	mov    %al,0x80119dc0
  mac_addr[1] = data_l>>8;
80108a03:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108a06:	c1 e8 08             	shr    $0x8,%eax
80108a09:	a2 c1 9d 11 80       	mov    %al,0x80119dc1
  uint data_m = i8254_read_eeprom(0x1);
80108a0e:	83 ec 0c             	sub    $0xc,%esp
80108a11:	6a 01                	push   $0x1
80108a13:	e8 c5 04 00 00       	call   80108edd <i8254_read_eeprom>
80108a18:	83 c4 10             	add    $0x10,%esp
80108a1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108a1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a21:	a2 c2 9d 11 80       	mov    %al,0x80119dc2
  mac_addr[3] = data_m>>8;
80108a26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108a29:	c1 e8 08             	shr    $0x8,%eax
80108a2c:	a2 c3 9d 11 80       	mov    %al,0x80119dc3
  uint data_h = i8254_read_eeprom(0x2);
80108a31:	83 ec 0c             	sub    $0xc,%esp
80108a34:	6a 02                	push   $0x2
80108a36:	e8 a2 04 00 00       	call   80108edd <i8254_read_eeprom>
80108a3b:	83 c4 10             	add    $0x10,%esp
80108a3e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108a41:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a44:	a2 c4 9d 11 80       	mov    %al,0x80119dc4
  mac_addr[5] = data_h>>8;
80108a49:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a4c:	c1 e8 08             	shr    $0x8,%eax
80108a4f:	a2 c5 9d 11 80       	mov    %al,0x80119dc5
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108a54:	0f b6 05 c5 9d 11 80 	movzbl 0x80119dc5,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a5b:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108a5e:	0f b6 05 c4 9d 11 80 	movzbl 0x80119dc4,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a65:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108a68:	0f b6 05 c3 9d 11 80 	movzbl 0x80119dc3,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a6f:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108a72:	0f b6 05 c2 9d 11 80 	movzbl 0x80119dc2,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a79:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
80108a7c:	0f b6 05 c1 9d 11 80 	movzbl 0x80119dc1,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a83:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108a86:	0f b6 05 c0 9d 11 80 	movzbl 0x80119dc0,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108a8d:	0f b6 c0             	movzbl %al,%eax
80108a90:	83 ec 04             	sub    $0x4,%esp
80108a93:	57                   	push   %edi
80108a94:	56                   	push   %esi
80108a95:	53                   	push   %ebx
80108a96:	51                   	push   %ecx
80108a97:	52                   	push   %edx
80108a98:	50                   	push   %eax
80108a99:	68 d8 c2 10 80       	push   $0x8010c2d8
80108a9e:	e8 51 79 ff ff       	call   801003f4 <cprintf>
80108aa3:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108aa6:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108aab:	05 00 54 00 00       	add    $0x5400,%eax
80108ab0:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108ab3:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ab8:	05 04 54 00 00       	add    $0x5404,%eax
80108abd:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
80108ac0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108ac3:	c1 e0 10             	shl    $0x10,%eax
80108ac6:	0b 45 d8             	or     -0x28(%ebp),%eax
80108ac9:	89 c2                	mov    %eax,%edx
80108acb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80108ace:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
80108ad0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ad3:	0d 00 00 00 80       	or     $0x80000000,%eax
80108ad8:	89 c2                	mov    %eax,%edx
80108ada:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108add:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
80108adf:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ae4:	05 00 52 00 00       	add    $0x5200,%eax
80108ae9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
80108aec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80108af3:	eb 19                	jmp    80108b0e <i8254_init_recv+0x12c>
    mta[i] = 0;
80108af5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108af8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108aff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108b02:	01 d0                	add    %edx,%eax
80108b04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
80108b0a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80108b0e:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
80108b12:	7e e1                	jle    80108af5 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
80108b14:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b19:	05 d0 00 00 00       	add    $0xd0,%eax
80108b1e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b21:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108b24:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108b2a:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b2f:	05 c8 00 00 00       	add    $0xc8,%eax
80108b34:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108b37:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108b3a:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108b40:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b45:	05 28 28 00 00       	add    $0x2828,%eax
80108b4a:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
80108b4d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108b50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108b56:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b5b:	05 00 01 00 00       	add    $0x100,%eax
80108b60:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108b63:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108b66:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
80108b6c:	e8 19 a1 ff ff       	call   80102c8a <kalloc>
80108b71:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b74:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b79:	05 00 28 00 00       	add    $0x2800,%eax
80108b7e:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108b81:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b86:	05 04 28 00 00       	add    $0x2804,%eax
80108b8b:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108b8e:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108b93:	05 08 28 00 00       	add    $0x2808,%eax
80108b98:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b9b:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ba0:	05 10 28 00 00       	add    $0x2810,%eax
80108ba5:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108ba8:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108bad:	05 18 28 00 00       	add    $0x2818,%eax
80108bb2:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108bb5:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108bb8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108bbe:	8b 45 ac             	mov    -0x54(%ebp),%eax
80108bc1:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
80108bc3:	8b 45 a8             	mov    -0x58(%ebp),%eax
80108bc6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
80108bcc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80108bcf:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
80108bd5:	8b 45 a0             	mov    -0x60(%ebp),%eax
80108bd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
80108bde:	8b 45 9c             	mov    -0x64(%ebp),%eax
80108be1:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
80108be7:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108bea:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108bed:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108bf4:	eb 73                	jmp    80108c69 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
80108bf6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bf9:	c1 e0 04             	shl    $0x4,%eax
80108bfc:	89 c2                	mov    %eax,%edx
80108bfe:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c01:	01 d0                	add    %edx,%eax
80108c03:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
80108c0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c0d:	c1 e0 04             	shl    $0x4,%eax
80108c10:	89 c2                	mov    %eax,%edx
80108c12:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c15:	01 d0                	add    %edx,%eax
80108c17:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
80108c1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c20:	c1 e0 04             	shl    $0x4,%eax
80108c23:	89 c2                	mov    %eax,%edx
80108c25:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c28:	01 d0                	add    %edx,%eax
80108c2a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108c30:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c33:	c1 e0 04             	shl    $0x4,%eax
80108c36:	89 c2                	mov    %eax,%edx
80108c38:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c3b:	01 d0                	add    %edx,%eax
80108c3d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108c41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c44:	c1 e0 04             	shl    $0x4,%eax
80108c47:	89 c2                	mov    %eax,%edx
80108c49:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c4c:	01 d0                	add    %edx,%eax
80108c4e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108c52:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c55:	c1 e0 04             	shl    $0x4,%eax
80108c58:	89 c2                	mov    %eax,%edx
80108c5a:	8b 45 98             	mov    -0x68(%ebp),%eax
80108c5d:	01 d0                	add    %edx,%eax
80108c5f:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108c65:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108c69:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108c70:	7e 84                	jle    80108bf6 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108c72:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108c79:	eb 57                	jmp    80108cd2 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108c7b:	e8 0a a0 ff ff       	call   80102c8a <kalloc>
80108c80:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108c83:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108c87:	75 12                	jne    80108c9b <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108c89:	83 ec 0c             	sub    $0xc,%esp
80108c8c:	68 f8 c2 10 80       	push   $0x8010c2f8
80108c91:	e8 5e 77 ff ff       	call   801003f4 <cprintf>
80108c96:	83 c4 10             	add    $0x10,%esp
      break;
80108c99:	eb 3d                	jmp    80108cd8 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108c9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c9e:	c1 e0 04             	shl    $0x4,%eax
80108ca1:	89 c2                	mov    %eax,%edx
80108ca3:	8b 45 98             	mov    -0x68(%ebp),%eax
80108ca6:	01 d0                	add    %edx,%eax
80108ca8:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108cab:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108cb1:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108cb3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cb6:	83 c0 01             	add    $0x1,%eax
80108cb9:	c1 e0 04             	shl    $0x4,%eax
80108cbc:	89 c2                	mov    %eax,%edx
80108cbe:	8b 45 98             	mov    -0x68(%ebp),%eax
80108cc1:	01 d0                	add    %edx,%eax
80108cc3:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108cc6:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108ccc:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108cce:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
80108cd2:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
80108cd6:	7e a3                	jle    80108c7b <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
80108cd8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108cdb:	8b 00                	mov    (%eax),%eax
80108cdd:	83 c8 02             	or     $0x2,%eax
80108ce0:	89 c2                	mov    %eax,%edx
80108ce2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108ce5:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
80108ce7:	83 ec 0c             	sub    $0xc,%esp
80108cea:	68 18 c3 10 80       	push   $0x8010c318
80108cef:	e8 00 77 ff ff       	call   801003f4 <cprintf>
80108cf4:	83 c4 10             	add    $0x10,%esp
}
80108cf7:	90                   	nop
80108cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108cfb:	5b                   	pop    %ebx
80108cfc:	5e                   	pop    %esi
80108cfd:	5f                   	pop    %edi
80108cfe:	5d                   	pop    %ebp
80108cff:	c3                   	ret

80108d00 <i8254_init_send>:

void i8254_init_send(){
80108d00:	55                   	push   %ebp
80108d01:	89 e5                	mov    %esp,%ebp
80108d03:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
80108d06:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d0b:	05 28 38 00 00       	add    $0x3828,%eax
80108d10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
80108d13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d16:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
80108d1c:	e8 69 9f ff ff       	call   80102c8a <kalloc>
80108d21:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108d24:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d29:	05 00 38 00 00       	add    $0x3800,%eax
80108d2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108d31:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d36:	05 04 38 00 00       	add    $0x3804,%eax
80108d3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108d3e:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d43:	05 08 38 00 00       	add    $0x3808,%eax
80108d48:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108d4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d4e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d57:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108d59:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108d5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108d62:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108d65:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108d6b:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d70:	05 10 38 00 00       	add    $0x3810,%eax
80108d75:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108d78:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108d7d:	05 18 38 00 00       	add    $0x3818,%eax
80108d82:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108d85:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108d88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108d8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108d97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d9a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108d9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108da4:	e9 82 00 00 00       	jmp    80108e2b <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dac:	c1 e0 04             	shl    $0x4,%eax
80108daf:	89 c2                	mov    %eax,%edx
80108db1:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108db4:	01 d0                	add    %edx,%eax
80108db6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
80108dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dc0:	c1 e0 04             	shl    $0x4,%eax
80108dc3:	89 c2                	mov    %eax,%edx
80108dc5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dc8:	01 d0                	add    %edx,%eax
80108dca:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
80108dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd3:	c1 e0 04             	shl    $0x4,%eax
80108dd6:	89 c2                	mov    %eax,%edx
80108dd8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108ddb:	01 d0                	add    %edx,%eax
80108ddd:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
80108de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de4:	c1 e0 04             	shl    $0x4,%eax
80108de7:	89 c2                	mov    %eax,%edx
80108de9:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dec:	01 d0                	add    %edx,%eax
80108dee:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
80108df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df5:	c1 e0 04             	shl    $0x4,%eax
80108df8:	89 c2                	mov    %eax,%edx
80108dfa:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108dfd:	01 d0                	add    %edx,%eax
80108dff:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
80108e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e06:	c1 e0 04             	shl    $0x4,%eax
80108e09:	89 c2                	mov    %eax,%edx
80108e0b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e0e:	01 d0                	add    %edx,%eax
80108e10:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
80108e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e17:	c1 e0 04             	shl    $0x4,%eax
80108e1a:	89 c2                	mov    %eax,%edx
80108e1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e1f:	01 d0                	add    %edx,%eax
80108e21:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108e27:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108e2b:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108e32:	0f 8e 71 ff ff ff    	jle    80108da9 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e38:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108e3f:	eb 57                	jmp    80108e98 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108e41:	e8 44 9e ff ff       	call   80102c8a <kalloc>
80108e46:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108e49:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108e4d:	75 12                	jne    80108e61 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108e4f:	83 ec 0c             	sub    $0xc,%esp
80108e52:	68 f8 c2 10 80       	push   $0x8010c2f8
80108e57:	e8 98 75 ff ff       	call   801003f4 <cprintf>
80108e5c:	83 c4 10             	add    $0x10,%esp
      break;
80108e5f:	eb 3d                	jmp    80108e9e <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e64:	c1 e0 04             	shl    $0x4,%eax
80108e67:	89 c2                	mov    %eax,%edx
80108e69:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e6c:	01 d0                	add    %edx,%eax
80108e6e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e71:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108e77:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e7c:	83 c0 01             	add    $0x1,%eax
80108e7f:	c1 e0 04             	shl    $0x4,%eax
80108e82:	89 c2                	mov    %eax,%edx
80108e84:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e87:	01 d0                	add    %edx,%eax
80108e89:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108e8c:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108e92:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108e94:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108e98:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108e9c:	7e a3                	jle    80108e41 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108e9e:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ea3:	05 00 04 00 00       	add    $0x400,%eax
80108ea8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108eab:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108eae:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108eb4:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108eb9:	05 10 04 00 00       	add    $0x410,%eax
80108ebe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108ec1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108ec4:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108eca:	83 ec 0c             	sub    $0xc,%esp
80108ecd:	68 38 c3 10 80       	push   $0x8010c338
80108ed2:	e8 1d 75 ff ff       	call   801003f4 <cprintf>
80108ed7:	83 c4 10             	add    $0x10,%esp

}
80108eda:	90                   	nop
80108edb:	c9                   	leave
80108edc:	c3                   	ret

80108edd <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108edd:	55                   	push   %ebp
80108ede:	89 e5                	mov    %esp,%ebp
80108ee0:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108ee3:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ee8:	83 c0 14             	add    $0x14,%eax
80108eeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108eee:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef1:	c1 e0 08             	shl    $0x8,%eax
80108ef4:	0f b7 c0             	movzwl %ax,%eax
80108ef7:	83 c8 01             	or     $0x1,%eax
80108efa:	89 c2                	mov    %eax,%edx
80108efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eff:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108f01:	83 ec 0c             	sub    $0xc,%esp
80108f04:	68 58 c3 10 80       	push   $0x8010c358
80108f09:	e8 e6 74 ff ff       	call   801003f4 <cprintf>
80108f0e:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f14:	8b 00                	mov    (%eax),%eax
80108f16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1c:	83 e0 10             	and    $0x10,%eax
80108f1f:	85 c0                	test   %eax,%eax
80108f21:	75 02                	jne    80108f25 <i8254_read_eeprom+0x48>
  while(1){
80108f23:	eb dc                	jmp    80108f01 <i8254_read_eeprom+0x24>
      break;
80108f25:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f29:	8b 00                	mov    (%eax),%eax
80108f2b:	c1 e8 10             	shr    $0x10,%eax
}
80108f2e:	c9                   	leave
80108f2f:	c3                   	ret

80108f30 <i8254_recv>:
void i8254_recv(){
80108f30:	55                   	push   %ebp
80108f31:	89 e5                	mov    %esp,%ebp
80108f33:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108f36:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f3b:	05 10 28 00 00       	add    $0x2810,%eax
80108f40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108f43:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f48:	05 18 28 00 00       	add    $0x2818,%eax
80108f4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108f50:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108f55:	05 00 28 00 00       	add    $0x2800,%eax
80108f5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108f5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f60:	8b 00                	mov    (%eax),%eax
80108f62:	05 00 00 00 80       	add    $0x80000000,%eax
80108f67:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6d:	8b 10                	mov    (%eax),%edx
80108f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f72:	8b 00                	mov    (%eax),%eax
80108f74:	29 c2                	sub    %eax,%edx
80108f76:	89 d0                	mov    %edx,%eax
80108f78:	25 ff 00 00 00       	and    $0xff,%eax
80108f7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108f80:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108f84:	7e 37                	jle    80108fbd <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108f86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f89:	8b 00                	mov    (%eax),%eax
80108f8b:	c1 e0 04             	shl    $0x4,%eax
80108f8e:	89 c2                	mov    %eax,%edx
80108f90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f93:	01 d0                	add    %edx,%eax
80108f95:	8b 00                	mov    (%eax),%eax
80108f97:	05 00 00 00 80       	add    $0x80000000,%eax
80108f9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa2:	8b 00                	mov    (%eax),%eax
80108fa4:	83 c0 01             	add    $0x1,%eax
80108fa7:	0f b6 d0             	movzbl %al,%edx
80108faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fad:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108faf:	83 ec 0c             	sub    $0xc,%esp
80108fb2:	ff 75 e0             	push   -0x20(%ebp)
80108fb5:	e8 13 09 00 00       	call   801098cd <eth_proc>
80108fba:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc0:	8b 10                	mov    (%eax),%edx
80108fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fc5:	8b 00                	mov    (%eax),%eax
80108fc7:	39 c2                	cmp    %eax,%edx
80108fc9:	75 9f                	jne    80108f6a <i8254_recv+0x3a>
      (*rdt)--;
80108fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fce:	8b 00                	mov    (%eax),%eax
80108fd0:	8d 50 ff             	lea    -0x1(%eax),%edx
80108fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd6:	89 10                	mov    %edx,(%eax)
  while(1){
80108fd8:	eb 90                	jmp    80108f6a <i8254_recv+0x3a>

80108fda <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108fda:	55                   	push   %ebp
80108fdb:	89 e5                	mov    %esp,%ebp
80108fdd:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108fe0:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108fe5:	05 10 38 00 00       	add    $0x3810,%eax
80108fea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108fed:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108ff2:	05 18 38 00 00       	add    $0x3818,%eax
80108ff7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108ffa:	a1 bc 9d 11 80       	mov    0x80119dbc,%eax
80108fff:	05 00 38 00 00       	add    $0x3800,%eax
80109004:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80109007:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010900a:	8b 00                	mov    (%eax),%eax
8010900c:	05 00 00 00 80       	add    $0x80000000,%eax
80109011:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80109014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109017:	8b 10                	mov    (%eax),%edx
80109019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010901c:	8b 00                	mov    (%eax),%eax
8010901e:	29 c2                	sub    %eax,%edx
80109020:	0f b6 c2             	movzbl %dl,%eax
80109023:	ba 00 01 00 00       	mov    $0x100,%edx
80109028:	29 c2                	sub    %eax,%edx
8010902a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
8010902d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109030:	8b 00                	mov    (%eax),%eax
80109032:	25 ff 00 00 00       	and    $0xff,%eax
80109037:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
8010903a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010903e:	0f 8e a8 00 00 00    	jle    801090ec <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80109044:	8b 45 08             	mov    0x8(%ebp),%eax
80109047:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010904a:	89 d1                	mov    %edx,%ecx
8010904c:	c1 e1 04             	shl    $0x4,%ecx
8010904f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80109052:	01 ca                	add    %ecx,%edx
80109054:	8b 12                	mov    (%edx),%edx
80109056:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010905c:	83 ec 04             	sub    $0x4,%esp
8010905f:	ff 75 0c             	push   0xc(%ebp)
80109062:	50                   	push   %eax
80109063:	52                   	push   %edx
80109064:	e8 d3 be ff ff       	call   80104f3c <memmove>
80109069:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
8010906c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010906f:	c1 e0 04             	shl    $0x4,%eax
80109072:	89 c2                	mov    %eax,%edx
80109074:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109077:	01 d0                	add    %edx,%eax
80109079:	8b 55 0c             	mov    0xc(%ebp),%edx
8010907c:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80109080:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109083:	c1 e0 04             	shl    $0x4,%eax
80109086:	89 c2                	mov    %eax,%edx
80109088:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010908b:	01 d0                	add    %edx,%eax
8010908d:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80109091:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109094:	c1 e0 04             	shl    $0x4,%eax
80109097:	89 c2                	mov    %eax,%edx
80109099:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010909c:	01 d0                	add    %edx,%eax
8010909e:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
801090a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090a5:	c1 e0 04             	shl    $0x4,%eax
801090a8:	89 c2                	mov    %eax,%edx
801090aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090ad:	01 d0                	add    %edx,%eax
801090af:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
801090b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090b6:	c1 e0 04             	shl    $0x4,%eax
801090b9:	89 c2                	mov    %eax,%edx
801090bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090be:	01 d0                	add    %edx,%eax
801090c0:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
801090c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090c9:	c1 e0 04             	shl    $0x4,%eax
801090cc:	89 c2                	mov    %eax,%edx
801090ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090d1:	01 d0                	add    %edx,%eax
801090d3:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
801090d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090da:	8b 00                	mov    (%eax),%eax
801090dc:	83 c0 01             	add    $0x1,%eax
801090df:	0f b6 d0             	movzbl %al,%edx
801090e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e5:	89 10                	mov    %edx,(%eax)
    return len;
801090e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801090ea:	eb 05                	jmp    801090f1 <i8254_send+0x117>
  }else{
    return -1;
801090ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801090f1:	c9                   	leave
801090f2:	c3                   	ret

801090f3 <i8254_intr>:

void i8254_intr(){
801090f3:	55                   	push   %ebp
801090f4:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
801090f6:	a1 c8 9d 11 80       	mov    0x80119dc8,%eax
801090fb:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80109101:	90                   	nop
80109102:	5d                   	pop    %ebp
80109103:	c3                   	ret

80109104 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80109104:	55                   	push   %ebp
80109105:	89 e5                	mov    %esp,%ebp
80109107:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
8010910a:	8b 45 08             	mov    0x8(%ebp),%eax
8010910d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80109110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109113:	0f b7 00             	movzwl (%eax),%eax
80109116:	66 3d 00 01          	cmp    $0x100,%ax
8010911a:	74 0a                	je     80109126 <arp_proc+0x22>
8010911c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109121:	e9 4f 01 00 00       	jmp    80109275 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80109126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109129:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010912d:	66 83 f8 08          	cmp    $0x8,%ax
80109131:	74 0a                	je     8010913d <arp_proc+0x39>
80109133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109138:	e9 38 01 00 00       	jmp    80109275 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
8010913d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109140:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80109144:	3c 06                	cmp    $0x6,%al
80109146:	74 0a                	je     80109152 <arp_proc+0x4e>
80109148:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010914d:	e9 23 01 00 00       	jmp    80109275 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80109152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109155:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80109159:	3c 04                	cmp    $0x4,%al
8010915b:	74 0a                	je     80109167 <arp_proc+0x63>
8010915d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109162:	e9 0e 01 00 00       	jmp    80109275 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80109167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916a:	83 c0 18             	add    $0x18,%eax
8010916d:	83 ec 04             	sub    $0x4,%esp
80109170:	6a 04                	push   $0x4
80109172:	50                   	push   %eax
80109173:	68 e4 f4 10 80       	push   $0x8010f4e4
80109178:	e8 67 bd ff ff       	call   80104ee4 <memcmp>
8010917d:	83 c4 10             	add    $0x10,%esp
80109180:	85 c0                	test   %eax,%eax
80109182:	74 27                	je     801091ab <arp_proc+0xa7>
80109184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109187:	83 c0 0e             	add    $0xe,%eax
8010918a:	83 ec 04             	sub    $0x4,%esp
8010918d:	6a 04                	push   $0x4
8010918f:	50                   	push   %eax
80109190:	68 e4 f4 10 80       	push   $0x8010f4e4
80109195:	e8 4a bd ff ff       	call   80104ee4 <memcmp>
8010919a:	83 c4 10             	add    $0x10,%esp
8010919d:	85 c0                	test   %eax,%eax
8010919f:	74 0a                	je     801091ab <arp_proc+0xa7>
801091a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091a6:	e9 ca 00 00 00       	jmp    80109275 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
801091ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ae:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801091b2:	66 3d 00 01          	cmp    $0x100,%ax
801091b6:	75 69                	jne    80109221 <arp_proc+0x11d>
801091b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091bb:	83 c0 18             	add    $0x18,%eax
801091be:	83 ec 04             	sub    $0x4,%esp
801091c1:	6a 04                	push   $0x4
801091c3:	50                   	push   %eax
801091c4:	68 e4 f4 10 80       	push   $0x8010f4e4
801091c9:	e8 16 bd ff ff       	call   80104ee4 <memcmp>
801091ce:	83 c4 10             	add    $0x10,%esp
801091d1:	85 c0                	test   %eax,%eax
801091d3:	75 4c                	jne    80109221 <arp_proc+0x11d>
    uint send = (uint)kalloc();
801091d5:	e8 b0 9a ff ff       	call   80102c8a <kalloc>
801091da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
801091dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
801091e4:	83 ec 04             	sub    $0x4,%esp
801091e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801091ea:	50                   	push   %eax
801091eb:	ff 75 f0             	push   -0x10(%ebp)
801091ee:	ff 75 f4             	push   -0xc(%ebp)
801091f1:	e8 1f 04 00 00       	call   80109615 <arp_reply_pkt_create>
801091f6:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
801091f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091fc:	83 ec 08             	sub    $0x8,%esp
801091ff:	50                   	push   %eax
80109200:	ff 75 f0             	push   -0x10(%ebp)
80109203:	e8 d2 fd ff ff       	call   80108fda <i8254_send>
80109208:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
8010920b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010920e:	83 ec 0c             	sub    $0xc,%esp
80109211:	50                   	push   %eax
80109212:	e8 d9 99 ff ff       	call   80102bf0 <kfree>
80109217:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
8010921a:	b8 02 00 00 00       	mov    $0x2,%eax
8010921f:	eb 54                	jmp    80109275 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80109221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109224:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109228:	66 3d 00 02          	cmp    $0x200,%ax
8010922c:	75 42                	jne    80109270 <arp_proc+0x16c>
8010922e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109231:	83 c0 18             	add    $0x18,%eax
80109234:	83 ec 04             	sub    $0x4,%esp
80109237:	6a 04                	push   $0x4
80109239:	50                   	push   %eax
8010923a:	68 e4 f4 10 80       	push   $0x8010f4e4
8010923f:	e8 a0 bc ff ff       	call   80104ee4 <memcmp>
80109244:	83 c4 10             	add    $0x10,%esp
80109247:	85 c0                	test   %eax,%eax
80109249:	75 25                	jne    80109270 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
8010924b:	83 ec 0c             	sub    $0xc,%esp
8010924e:	68 5c c3 10 80       	push   $0x8010c35c
80109253:	e8 9c 71 ff ff       	call   801003f4 <cprintf>
80109258:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
8010925b:	83 ec 0c             	sub    $0xc,%esp
8010925e:	ff 75 f4             	push   -0xc(%ebp)
80109261:	e8 af 01 00 00       	call   80109415 <arp_table_update>
80109266:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80109269:	b8 01 00 00 00       	mov    $0x1,%eax
8010926e:	eb 05                	jmp    80109275 <arp_proc+0x171>
  }else{
    return -1;
80109270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80109275:	c9                   	leave
80109276:	c3                   	ret

80109277 <arp_scan>:

void arp_scan(){
80109277:	55                   	push   %ebp
80109278:	89 e5                	mov    %esp,%ebp
8010927a:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
8010927d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109284:	eb 6f                	jmp    801092f5 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80109286:	e8 ff 99 ff ff       	call   80102c8a <kalloc>
8010928b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
8010928e:	83 ec 04             	sub    $0x4,%esp
80109291:	ff 75 f4             	push   -0xc(%ebp)
80109294:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109297:	50                   	push   %eax
80109298:	ff 75 ec             	push   -0x14(%ebp)
8010929b:	e8 62 00 00 00       	call   80109302 <arp_broadcast>
801092a0:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
801092a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092a6:	83 ec 08             	sub    $0x8,%esp
801092a9:	50                   	push   %eax
801092aa:	ff 75 ec             	push   -0x14(%ebp)
801092ad:	e8 28 fd ff ff       	call   80108fda <i8254_send>
801092b2:	83 c4 10             	add    $0x10,%esp
801092b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801092b8:	eb 22                	jmp    801092dc <arp_scan+0x65>
      microdelay(1);
801092ba:	83 ec 0c             	sub    $0xc,%esp
801092bd:	6a 01                	push   $0x1
801092bf:	e8 57 9d ff ff       	call   8010301b <microdelay>
801092c4:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
801092c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092ca:	83 ec 08             	sub    $0x8,%esp
801092cd:	50                   	push   %eax
801092ce:	ff 75 ec             	push   -0x14(%ebp)
801092d1:	e8 04 fd ff ff       	call   80108fda <i8254_send>
801092d6:	83 c4 10             	add    $0x10,%esp
801092d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
801092dc:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801092e0:	74 d8                	je     801092ba <arp_scan+0x43>
    }
    kfree((char *)send);
801092e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092e5:	83 ec 0c             	sub    $0xc,%esp
801092e8:	50                   	push   %eax
801092e9:	e8 02 99 ff ff       	call   80102bf0 <kfree>
801092ee:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
801092f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801092f5:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801092fc:	7e 88                	jle    80109286 <arp_scan+0xf>
  }
}
801092fe:	90                   	nop
801092ff:	90                   	nop
80109300:	c9                   	leave
80109301:	c3                   	ret

80109302 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80109302:	55                   	push   %ebp
80109303:	89 e5                	mov    %esp,%ebp
80109305:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80109308:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
8010930c:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80109310:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80109314:	8b 45 10             	mov    0x10(%ebp),%eax
80109317:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
8010931a:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80109321:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80109327:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
8010932e:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80109334:	8b 45 0c             	mov    0xc(%ebp),%eax
80109337:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
8010933d:	8b 45 08             	mov    0x8(%ebp),%eax
80109340:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109343:	8b 45 08             	mov    0x8(%ebp),%eax
80109346:	83 c0 0e             	add    $0xe,%eax
80109349:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
8010934c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010934f:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109356:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
8010935a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010935d:	83 ec 04             	sub    $0x4,%esp
80109360:	6a 06                	push   $0x6
80109362:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80109365:	52                   	push   %edx
80109366:	50                   	push   %eax
80109367:	e8 d0 bb ff ff       	call   80104f3c <memmove>
8010936c:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010936f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109372:	83 c0 06             	add    $0x6,%eax
80109375:	83 ec 04             	sub    $0x4,%esp
80109378:	6a 06                	push   $0x6
8010937a:	68 c0 9d 11 80       	push   $0x80119dc0
8010937f:	50                   	push   %eax
80109380:	e8 b7 bb ff ff       	call   80104f3c <memmove>
80109385:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010938b:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109393:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010939c:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
801093a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093a3:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
801093a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093aa:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
801093b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093b3:	8d 50 12             	lea    0x12(%eax),%edx
801093b6:	83 ec 04             	sub    $0x4,%esp
801093b9:	6a 06                	push   $0x6
801093bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801093be:	50                   	push   %eax
801093bf:	52                   	push   %edx
801093c0:	e8 77 bb ff ff       	call   80104f3c <memmove>
801093c5:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
801093c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cb:	8d 50 18             	lea    0x18(%eax),%edx
801093ce:	83 ec 04             	sub    $0x4,%esp
801093d1:	6a 04                	push   $0x4
801093d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801093d6:	50                   	push   %eax
801093d7:	52                   	push   %edx
801093d8:	e8 5f bb ff ff       	call   80104f3c <memmove>
801093dd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801093e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e3:	83 c0 08             	add    $0x8,%eax
801093e6:	83 ec 04             	sub    $0x4,%esp
801093e9:	6a 06                	push   $0x6
801093eb:	68 c0 9d 11 80       	push   $0x80119dc0
801093f0:	50                   	push   %eax
801093f1:	e8 46 bb ff ff       	call   80104f3c <memmove>
801093f6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801093f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093fc:	83 c0 0e             	add    $0xe,%eax
801093ff:	83 ec 04             	sub    $0x4,%esp
80109402:	6a 04                	push   $0x4
80109404:	68 e4 f4 10 80       	push   $0x8010f4e4
80109409:	50                   	push   %eax
8010940a:	e8 2d bb ff ff       	call   80104f3c <memmove>
8010940f:	83 c4 10             	add    $0x10,%esp
}
80109412:	90                   	nop
80109413:	c9                   	leave
80109414:	c3                   	ret

80109415 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80109415:	55                   	push   %ebp
80109416:	89 e5                	mov    %esp,%ebp
80109418:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
8010941b:	8b 45 08             	mov    0x8(%ebp),%eax
8010941e:	83 c0 0e             	add    $0xe,%eax
80109421:	83 ec 0c             	sub    $0xc,%esp
80109424:	50                   	push   %eax
80109425:	e8 bc 00 00 00       	call   801094e6 <arp_table_search>
8010942a:	83 c4 10             	add    $0x10,%esp
8010942d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80109430:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109434:	78 2d                	js     80109463 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109436:	8b 45 08             	mov    0x8(%ebp),%eax
80109439:	8d 48 08             	lea    0x8(%eax),%ecx
8010943c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010943f:	89 d0                	mov    %edx,%eax
80109441:	c1 e0 02             	shl    $0x2,%eax
80109444:	01 d0                	add    %edx,%eax
80109446:	01 c0                	add    %eax,%eax
80109448:	01 d0                	add    %edx,%eax
8010944a:	05 e0 9d 11 80       	add    $0x80119de0,%eax
8010944f:	83 c0 04             	add    $0x4,%eax
80109452:	83 ec 04             	sub    $0x4,%esp
80109455:	6a 06                	push   $0x6
80109457:	51                   	push   %ecx
80109458:	50                   	push   %eax
80109459:	e8 de ba ff ff       	call   80104f3c <memmove>
8010945e:	83 c4 10             	add    $0x10,%esp
80109461:	eb 70                	jmp    801094d3 <arp_table_update+0xbe>
  }else{
    index += 1;
80109463:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109467:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
8010946a:	8b 45 08             	mov    0x8(%ebp),%eax
8010946d:	8d 48 08             	lea    0x8(%eax),%ecx
80109470:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109473:	89 d0                	mov    %edx,%eax
80109475:	c1 e0 02             	shl    $0x2,%eax
80109478:	01 d0                	add    %edx,%eax
8010947a:	01 c0                	add    %eax,%eax
8010947c:	01 d0                	add    %edx,%eax
8010947e:	05 e0 9d 11 80       	add    $0x80119de0,%eax
80109483:	83 c0 04             	add    $0x4,%eax
80109486:	83 ec 04             	sub    $0x4,%esp
80109489:	6a 06                	push   $0x6
8010948b:	51                   	push   %ecx
8010948c:	50                   	push   %eax
8010948d:	e8 aa ba ff ff       	call   80104f3c <memmove>
80109492:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109495:	8b 45 08             	mov    0x8(%ebp),%eax
80109498:	8d 48 0e             	lea    0xe(%eax),%ecx
8010949b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010949e:	89 d0                	mov    %edx,%eax
801094a0:	c1 e0 02             	shl    $0x2,%eax
801094a3:	01 d0                	add    %edx,%eax
801094a5:	01 c0                	add    %eax,%eax
801094a7:	01 d0                	add    %edx,%eax
801094a9:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801094ae:	83 ec 04             	sub    $0x4,%esp
801094b1:	6a 04                	push   $0x4
801094b3:	51                   	push   %ecx
801094b4:	50                   	push   %eax
801094b5:	e8 82 ba ff ff       	call   80104f3c <memmove>
801094ba:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
801094bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801094c0:	89 d0                	mov    %edx,%eax
801094c2:	c1 e0 02             	shl    $0x2,%eax
801094c5:	01 d0                	add    %edx,%eax
801094c7:	01 c0                	add    %eax,%eax
801094c9:	01 d0                	add    %edx,%eax
801094cb:	05 ea 9d 11 80       	add    $0x80119dea,%eax
801094d0:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801094d3:	83 ec 0c             	sub    $0xc,%esp
801094d6:	68 e0 9d 11 80       	push   $0x80119de0
801094db:	e8 83 00 00 00       	call   80109563 <print_arp_table>
801094e0:	83 c4 10             	add    $0x10,%esp
}
801094e3:	90                   	nop
801094e4:	c9                   	leave
801094e5:	c3                   	ret

801094e6 <arp_table_search>:

int arp_table_search(uchar *ip){
801094e6:	55                   	push   %ebp
801094e7:	89 e5                	mov    %esp,%ebp
801094e9:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801094ec:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801094f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801094fa:	eb 59                	jmp    80109555 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801094fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801094ff:	89 d0                	mov    %edx,%eax
80109501:	c1 e0 02             	shl    $0x2,%eax
80109504:	01 d0                	add    %edx,%eax
80109506:	01 c0                	add    %eax,%eax
80109508:	01 d0                	add    %edx,%eax
8010950a:	05 e0 9d 11 80       	add    $0x80119de0,%eax
8010950f:	83 ec 04             	sub    $0x4,%esp
80109512:	6a 04                	push   $0x4
80109514:	ff 75 08             	push   0x8(%ebp)
80109517:	50                   	push   %eax
80109518:	e8 c7 b9 ff ff       	call   80104ee4 <memcmp>
8010951d:	83 c4 10             	add    $0x10,%esp
80109520:	85 c0                	test   %eax,%eax
80109522:	75 05                	jne    80109529 <arp_table_search+0x43>
      return i;
80109524:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109527:	eb 38                	jmp    80109561 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109529:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010952c:	89 d0                	mov    %edx,%eax
8010952e:	c1 e0 02             	shl    $0x2,%eax
80109531:	01 d0                	add    %edx,%eax
80109533:	01 c0                	add    %eax,%eax
80109535:	01 d0                	add    %edx,%eax
80109537:	05 ea 9d 11 80       	add    $0x80119dea,%eax
8010953c:	0f b6 00             	movzbl (%eax),%eax
8010953f:	84 c0                	test   %al,%al
80109541:	75 0e                	jne    80109551 <arp_table_search+0x6b>
80109543:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109547:	75 08                	jne    80109551 <arp_table_search+0x6b>
      empty = -i;
80109549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010954c:	f7 d8                	neg    %eax
8010954e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109551:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109555:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109559:	7e a1                	jle    801094fc <arp_table_search+0x16>
    }
  }
  return empty-1;
8010955b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010955e:	83 e8 01             	sub    $0x1,%eax
}
80109561:	c9                   	leave
80109562:	c3                   	ret

80109563 <print_arp_table>:

void print_arp_table(){
80109563:	55                   	push   %ebp
80109564:	89 e5                	mov    %esp,%ebp
80109566:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109570:	e9 92 00 00 00       	jmp    80109607 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109575:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109578:	89 d0                	mov    %edx,%eax
8010957a:	c1 e0 02             	shl    $0x2,%eax
8010957d:	01 d0                	add    %edx,%eax
8010957f:	01 c0                	add    %eax,%eax
80109581:	01 d0                	add    %edx,%eax
80109583:	05 ea 9d 11 80       	add    $0x80119dea,%eax
80109588:	0f b6 00             	movzbl (%eax),%eax
8010958b:	84 c0                	test   %al,%al
8010958d:	74 74                	je     80109603 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010958f:	83 ec 08             	sub    $0x8,%esp
80109592:	ff 75 f4             	push   -0xc(%ebp)
80109595:	68 6f c3 10 80       	push   $0x8010c36f
8010959a:	e8 55 6e ff ff       	call   801003f4 <cprintf>
8010959f:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
801095a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095a5:	89 d0                	mov    %edx,%eax
801095a7:	c1 e0 02             	shl    $0x2,%eax
801095aa:	01 d0                	add    %edx,%eax
801095ac:	01 c0                	add    %eax,%eax
801095ae:	01 d0                	add    %edx,%eax
801095b0:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801095b5:	83 ec 0c             	sub    $0xc,%esp
801095b8:	50                   	push   %eax
801095b9:	e8 54 02 00 00       	call   80109812 <print_ipv4>
801095be:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801095c1:	83 ec 0c             	sub    $0xc,%esp
801095c4:	68 7e c3 10 80       	push   $0x8010c37e
801095c9:	e8 26 6e ff ff       	call   801003f4 <cprintf>
801095ce:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801095d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801095d4:	89 d0                	mov    %edx,%eax
801095d6:	c1 e0 02             	shl    $0x2,%eax
801095d9:	01 d0                	add    %edx,%eax
801095db:	01 c0                	add    %eax,%eax
801095dd:	01 d0                	add    %edx,%eax
801095df:	05 e0 9d 11 80       	add    $0x80119de0,%eax
801095e4:	83 c0 04             	add    $0x4,%eax
801095e7:	83 ec 0c             	sub    $0xc,%esp
801095ea:	50                   	push   %eax
801095eb:	e8 70 02 00 00       	call   80109860 <print_mac>
801095f0:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801095f3:	83 ec 0c             	sub    $0xc,%esp
801095f6:	68 80 c3 10 80       	push   $0x8010c380
801095fb:	e8 f4 6d ff ff       	call   801003f4 <cprintf>
80109600:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109603:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109607:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
8010960b:	0f 8e 64 ff ff ff    	jle    80109575 <print_arp_table+0x12>
    }
  }
}
80109611:	90                   	nop
80109612:	90                   	nop
80109613:	c9                   	leave
80109614:	c3                   	ret

80109615 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
80109615:	55                   	push   %ebp
80109616:	89 e5                	mov    %esp,%ebp
80109618:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
8010961b:	8b 45 10             	mov    0x10(%ebp),%eax
8010961e:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109624:	8b 45 0c             	mov    0xc(%ebp),%eax
80109627:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010962a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010962d:	83 c0 0e             	add    $0xe,%eax
80109630:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109636:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010963a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963d:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109641:	8b 45 08             	mov    0x8(%ebp),%eax
80109644:	8d 50 08             	lea    0x8(%eax),%edx
80109647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010964a:	83 ec 04             	sub    $0x4,%esp
8010964d:	6a 06                	push   $0x6
8010964f:	52                   	push   %edx
80109650:	50                   	push   %eax
80109651:	e8 e6 b8 ff ff       	call   80104f3c <memmove>
80109656:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010965c:	83 c0 06             	add    $0x6,%eax
8010965f:	83 ec 04             	sub    $0x4,%esp
80109662:	6a 06                	push   $0x6
80109664:	68 c0 9d 11 80       	push   $0x80119dc0
80109669:	50                   	push   %eax
8010966a:	e8 cd b8 ff ff       	call   80104f3c <memmove>
8010966f:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109675:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010967a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010967d:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109686:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010968a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010968d:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109691:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109694:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010969a:	8b 45 08             	mov    0x8(%ebp),%eax
8010969d:	8d 50 08             	lea    0x8(%eax),%edx
801096a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a3:	83 c0 12             	add    $0x12,%eax
801096a6:	83 ec 04             	sub    $0x4,%esp
801096a9:	6a 06                	push   $0x6
801096ab:	52                   	push   %edx
801096ac:	50                   	push   %eax
801096ad:	e8 8a b8 ff ff       	call   80104f3c <memmove>
801096b2:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
801096b5:	8b 45 08             	mov    0x8(%ebp),%eax
801096b8:	8d 50 0e             	lea    0xe(%eax),%edx
801096bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096be:	83 c0 18             	add    $0x18,%eax
801096c1:	83 ec 04             	sub    $0x4,%esp
801096c4:	6a 04                	push   $0x4
801096c6:	52                   	push   %edx
801096c7:	50                   	push   %eax
801096c8:	e8 6f b8 ff ff       	call   80104f3c <memmove>
801096cd:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801096d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d3:	83 c0 08             	add    $0x8,%eax
801096d6:	83 ec 04             	sub    $0x4,%esp
801096d9:	6a 06                	push   $0x6
801096db:	68 c0 9d 11 80       	push   $0x80119dc0
801096e0:	50                   	push   %eax
801096e1:	e8 56 b8 ff ff       	call   80104f3c <memmove>
801096e6:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801096e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096ec:	83 c0 0e             	add    $0xe,%eax
801096ef:	83 ec 04             	sub    $0x4,%esp
801096f2:	6a 04                	push   $0x4
801096f4:	68 e4 f4 10 80       	push   $0x8010f4e4
801096f9:	50                   	push   %eax
801096fa:	e8 3d b8 ff ff       	call   80104f3c <memmove>
801096ff:	83 c4 10             	add    $0x10,%esp
}
80109702:	90                   	nop
80109703:	c9                   	leave
80109704:	c3                   	ret

80109705 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
80109705:	55                   	push   %ebp
80109706:	89 e5                	mov    %esp,%ebp
80109708:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
8010970b:	83 ec 0c             	sub    $0xc,%esp
8010970e:	68 82 c3 10 80       	push   $0x8010c382
80109713:	e8 dc 6c ff ff       	call   801003f4 <cprintf>
80109718:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
8010971b:	8b 45 08             	mov    0x8(%ebp),%eax
8010971e:	83 c0 0e             	add    $0xe,%eax
80109721:	83 ec 0c             	sub    $0xc,%esp
80109724:	50                   	push   %eax
80109725:	e8 e8 00 00 00       	call   80109812 <print_ipv4>
8010972a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010972d:	83 ec 0c             	sub    $0xc,%esp
80109730:	68 80 c3 10 80       	push   $0x8010c380
80109735:	e8 ba 6c ff ff       	call   801003f4 <cprintf>
8010973a:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010973d:	8b 45 08             	mov    0x8(%ebp),%eax
80109740:	83 c0 08             	add    $0x8,%eax
80109743:	83 ec 0c             	sub    $0xc,%esp
80109746:	50                   	push   %eax
80109747:	e8 14 01 00 00       	call   80109860 <print_mac>
8010974c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010974f:	83 ec 0c             	sub    $0xc,%esp
80109752:	68 80 c3 10 80       	push   $0x8010c380
80109757:	e8 98 6c ff ff       	call   801003f4 <cprintf>
8010975c:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010975f:	83 ec 0c             	sub    $0xc,%esp
80109762:	68 99 c3 10 80       	push   $0x8010c399
80109767:	e8 88 6c ff ff       	call   801003f4 <cprintf>
8010976c:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010976f:	8b 45 08             	mov    0x8(%ebp),%eax
80109772:	83 c0 18             	add    $0x18,%eax
80109775:	83 ec 0c             	sub    $0xc,%esp
80109778:	50                   	push   %eax
80109779:	e8 94 00 00 00       	call   80109812 <print_ipv4>
8010977e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109781:	83 ec 0c             	sub    $0xc,%esp
80109784:	68 80 c3 10 80       	push   $0x8010c380
80109789:	e8 66 6c ff ff       	call   801003f4 <cprintf>
8010978e:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109791:	8b 45 08             	mov    0x8(%ebp),%eax
80109794:	83 c0 12             	add    $0x12,%eax
80109797:	83 ec 0c             	sub    $0xc,%esp
8010979a:	50                   	push   %eax
8010979b:	e8 c0 00 00 00       	call   80109860 <print_mac>
801097a0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801097a3:	83 ec 0c             	sub    $0xc,%esp
801097a6:	68 80 c3 10 80       	push   $0x8010c380
801097ab:	e8 44 6c ff ff       	call   801003f4 <cprintf>
801097b0:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
801097b3:	83 ec 0c             	sub    $0xc,%esp
801097b6:	68 b0 c3 10 80       	push   $0x8010c3b0
801097bb:	e8 34 6c ff ff       	call   801003f4 <cprintf>
801097c0:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801097c3:	8b 45 08             	mov    0x8(%ebp),%eax
801097c6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097ca:	66 3d 00 01          	cmp    $0x100,%ax
801097ce:	75 12                	jne    801097e2 <print_arp_info+0xdd>
801097d0:	83 ec 0c             	sub    $0xc,%esp
801097d3:	68 bc c3 10 80       	push   $0x8010c3bc
801097d8:	e8 17 6c ff ff       	call   801003f4 <cprintf>
801097dd:	83 c4 10             	add    $0x10,%esp
801097e0:	eb 1d                	jmp    801097ff <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801097e2:	8b 45 08             	mov    0x8(%ebp),%eax
801097e5:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801097e9:	66 3d 00 02          	cmp    $0x200,%ax
801097ed:	75 10                	jne    801097ff <print_arp_info+0xfa>
    cprintf("Reply\n");
801097ef:	83 ec 0c             	sub    $0xc,%esp
801097f2:	68 c5 c3 10 80       	push   $0x8010c3c5
801097f7:	e8 f8 6b ff ff       	call   801003f4 <cprintf>
801097fc:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801097ff:	83 ec 0c             	sub    $0xc,%esp
80109802:	68 80 c3 10 80       	push   $0x8010c380
80109807:	e8 e8 6b ff ff       	call   801003f4 <cprintf>
8010980c:	83 c4 10             	add    $0x10,%esp
}
8010980f:	90                   	nop
80109810:	c9                   	leave
80109811:	c3                   	ret

80109812 <print_ipv4>:

void print_ipv4(uchar *ip){
80109812:	55                   	push   %ebp
80109813:	89 e5                	mov    %esp,%ebp
80109815:	53                   	push   %ebx
80109816:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
80109819:	8b 45 08             	mov    0x8(%ebp),%eax
8010981c:	83 c0 03             	add    $0x3,%eax
8010981f:	0f b6 00             	movzbl (%eax),%eax
80109822:	0f b6 d8             	movzbl %al,%ebx
80109825:	8b 45 08             	mov    0x8(%ebp),%eax
80109828:	83 c0 02             	add    $0x2,%eax
8010982b:	0f b6 00             	movzbl (%eax),%eax
8010982e:	0f b6 c8             	movzbl %al,%ecx
80109831:	8b 45 08             	mov    0x8(%ebp),%eax
80109834:	83 c0 01             	add    $0x1,%eax
80109837:	0f b6 00             	movzbl (%eax),%eax
8010983a:	0f b6 d0             	movzbl %al,%edx
8010983d:	8b 45 08             	mov    0x8(%ebp),%eax
80109840:	0f b6 00             	movzbl (%eax),%eax
80109843:	0f b6 c0             	movzbl %al,%eax
80109846:	83 ec 0c             	sub    $0xc,%esp
80109849:	53                   	push   %ebx
8010984a:	51                   	push   %ecx
8010984b:	52                   	push   %edx
8010984c:	50                   	push   %eax
8010984d:	68 cc c3 10 80       	push   $0x8010c3cc
80109852:	e8 9d 6b ff ff       	call   801003f4 <cprintf>
80109857:	83 c4 20             	add    $0x20,%esp
}
8010985a:	90                   	nop
8010985b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010985e:	c9                   	leave
8010985f:	c3                   	ret

80109860 <print_mac>:

void print_mac(uchar *mac){
80109860:	55                   	push   %ebp
80109861:	89 e5                	mov    %esp,%ebp
80109863:	57                   	push   %edi
80109864:	56                   	push   %esi
80109865:	53                   	push   %ebx
80109866:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109869:	8b 45 08             	mov    0x8(%ebp),%eax
8010986c:	83 c0 05             	add    $0x5,%eax
8010986f:	0f b6 00             	movzbl (%eax),%eax
80109872:	0f b6 f8             	movzbl %al,%edi
80109875:	8b 45 08             	mov    0x8(%ebp),%eax
80109878:	83 c0 04             	add    $0x4,%eax
8010987b:	0f b6 00             	movzbl (%eax),%eax
8010987e:	0f b6 f0             	movzbl %al,%esi
80109881:	8b 45 08             	mov    0x8(%ebp),%eax
80109884:	83 c0 03             	add    $0x3,%eax
80109887:	0f b6 00             	movzbl (%eax),%eax
8010988a:	0f b6 d8             	movzbl %al,%ebx
8010988d:	8b 45 08             	mov    0x8(%ebp),%eax
80109890:	83 c0 02             	add    $0x2,%eax
80109893:	0f b6 00             	movzbl (%eax),%eax
80109896:	0f b6 c8             	movzbl %al,%ecx
80109899:	8b 45 08             	mov    0x8(%ebp),%eax
8010989c:	83 c0 01             	add    $0x1,%eax
8010989f:	0f b6 00             	movzbl (%eax),%eax
801098a2:	0f b6 d0             	movzbl %al,%edx
801098a5:	8b 45 08             	mov    0x8(%ebp),%eax
801098a8:	0f b6 00             	movzbl (%eax),%eax
801098ab:	0f b6 c0             	movzbl %al,%eax
801098ae:	83 ec 04             	sub    $0x4,%esp
801098b1:	57                   	push   %edi
801098b2:	56                   	push   %esi
801098b3:	53                   	push   %ebx
801098b4:	51                   	push   %ecx
801098b5:	52                   	push   %edx
801098b6:	50                   	push   %eax
801098b7:	68 e4 c3 10 80       	push   $0x8010c3e4
801098bc:	e8 33 6b ff ff       	call   801003f4 <cprintf>
801098c1:	83 c4 20             	add    $0x20,%esp
}
801098c4:	90                   	nop
801098c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801098c8:	5b                   	pop    %ebx
801098c9:	5e                   	pop    %esi
801098ca:	5f                   	pop    %edi
801098cb:	5d                   	pop    %ebp
801098cc:	c3                   	ret

801098cd <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801098cd:	55                   	push   %ebp
801098ce:	89 e5                	mov    %esp,%ebp
801098d0:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801098d3:	8b 45 08             	mov    0x8(%ebp),%eax
801098d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801098d9:	8b 45 08             	mov    0x8(%ebp),%eax
801098dc:	83 c0 0e             	add    $0xe,%eax
801098df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801098e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098e5:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801098e9:	3c 08                	cmp    $0x8,%al
801098eb:	75 1b                	jne    80109908 <eth_proc+0x3b>
801098ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098f0:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801098f4:	3c 06                	cmp    $0x6,%al
801098f6:	75 10                	jne    80109908 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801098f8:	83 ec 0c             	sub    $0xc,%esp
801098fb:	ff 75 f0             	push   -0x10(%ebp)
801098fe:	e8 01 f8 ff ff       	call   80109104 <arp_proc>
80109903:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
80109906:	eb 24                	jmp    8010992c <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
80109908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010990b:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010990f:	3c 08                	cmp    $0x8,%al
80109911:	75 19                	jne    8010992c <eth_proc+0x5f>
80109913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109916:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010991a:	84 c0                	test   %al,%al
8010991c:	75 0e                	jne    8010992c <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
8010991e:	83 ec 0c             	sub    $0xc,%esp
80109921:	ff 75 08             	push   0x8(%ebp)
80109924:	e8 8d 00 00 00       	call   801099b6 <ipv4_proc>
80109929:	83 c4 10             	add    $0x10,%esp
}
8010992c:	90                   	nop
8010992d:	c9                   	leave
8010992e:	c3                   	ret

8010992f <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010992f:	55                   	push   %ebp
80109930:	89 e5                	mov    %esp,%ebp
80109932:	83 ec 04             	sub    $0x4,%esp
80109935:	8b 45 08             	mov    0x8(%ebp),%eax
80109938:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010993c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109940:	66 c1 c0 08          	rol    $0x8,%ax
}
80109944:	c9                   	leave
80109945:	c3                   	ret

80109946 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109946:	55                   	push   %ebp
80109947:	89 e5                	mov    %esp,%ebp
80109949:	83 ec 04             	sub    $0x4,%esp
8010994c:	8b 45 08             	mov    0x8(%ebp),%eax
8010994f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109953:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109957:	66 c1 c0 08          	rol    $0x8,%ax
}
8010995b:	c9                   	leave
8010995c:	c3                   	ret

8010995d <H2N_uint>:

uint H2N_uint(uint value){
8010995d:	55                   	push   %ebp
8010995e:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109960:	8b 45 08             	mov    0x8(%ebp),%eax
80109963:	c1 e0 18             	shl    $0x18,%eax
80109966:	25 00 00 00 0f       	and    $0xf000000,%eax
8010996b:	89 c2                	mov    %eax,%edx
8010996d:	8b 45 08             	mov    0x8(%ebp),%eax
80109970:	c1 e0 08             	shl    $0x8,%eax
80109973:	25 00 f0 00 00       	and    $0xf000,%eax
80109978:	09 c2                	or     %eax,%edx
8010997a:	8b 45 08             	mov    0x8(%ebp),%eax
8010997d:	c1 e8 08             	shr    $0x8,%eax
80109980:	83 e0 0f             	and    $0xf,%eax
80109983:	01 d0                	add    %edx,%eax
}
80109985:	5d                   	pop    %ebp
80109986:	c3                   	ret

80109987 <N2H_uint>:

uint N2H_uint(uint value){
80109987:	55                   	push   %ebp
80109988:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010998a:	8b 45 08             	mov    0x8(%ebp),%eax
8010998d:	c1 e0 18             	shl    $0x18,%eax
80109990:	89 c2                	mov    %eax,%edx
80109992:	8b 45 08             	mov    0x8(%ebp),%eax
80109995:	c1 e0 08             	shl    $0x8,%eax
80109998:	25 00 00 ff 00       	and    $0xff0000,%eax
8010999d:	01 c2                	add    %eax,%edx
8010999f:	8b 45 08             	mov    0x8(%ebp),%eax
801099a2:	c1 e8 08             	shr    $0x8,%eax
801099a5:	25 00 ff 00 00       	and    $0xff00,%eax
801099aa:	01 c2                	add    %eax,%edx
801099ac:	8b 45 08             	mov    0x8(%ebp),%eax
801099af:	c1 e8 18             	shr    $0x18,%eax
801099b2:	01 d0                	add    %edx,%eax
}
801099b4:	5d                   	pop    %ebp
801099b5:	c3                   	ret

801099b6 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
801099b6:	55                   	push   %ebp
801099b7:	89 e5                	mov    %esp,%ebp
801099b9:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
801099bc:	8b 45 08             	mov    0x8(%ebp),%eax
801099bf:	83 c0 0e             	add    $0xe,%eax
801099c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801099c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099c8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099cc:	0f b7 d0             	movzwl %ax,%edx
801099cf:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801099d4:	39 c2                	cmp    %eax,%edx
801099d6:	74 60                	je     80109a38 <ipv4_proc+0x82>
801099d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099db:	83 c0 0c             	add    $0xc,%eax
801099de:	83 ec 04             	sub    $0x4,%esp
801099e1:	6a 04                	push   $0x4
801099e3:	50                   	push   %eax
801099e4:	68 e4 f4 10 80       	push   $0x8010f4e4
801099e9:	e8 f6 b4 ff ff       	call   80104ee4 <memcmp>
801099ee:	83 c4 10             	add    $0x10,%esp
801099f1:	85 c0                	test   %eax,%eax
801099f3:	74 43                	je     80109a38 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801099f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099f8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801099fc:	0f b7 c0             	movzwl %ax,%eax
801099ff:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
80109a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a07:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a0b:	3c 01                	cmp    $0x1,%al
80109a0d:	75 10                	jne    80109a1f <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
80109a0f:	83 ec 0c             	sub    $0xc,%esp
80109a12:	ff 75 08             	push   0x8(%ebp)
80109a15:	e8 a3 00 00 00       	call   80109abd <icmp_proc>
80109a1a:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
80109a1d:	eb 19                	jmp    80109a38 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a22:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109a26:	3c 06                	cmp    $0x6,%al
80109a28:	75 0e                	jne    80109a38 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109a2a:	83 ec 0c             	sub    $0xc,%esp
80109a2d:	ff 75 08             	push   0x8(%ebp)
80109a30:	e8 b3 03 00 00       	call   80109de8 <tcp_proc>
80109a35:	83 c4 10             	add    $0x10,%esp
}
80109a38:	90                   	nop
80109a39:	c9                   	leave
80109a3a:	c3                   	ret

80109a3b <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109a3b:	55                   	push   %ebp
80109a3c:	89 e5                	mov    %esp,%ebp
80109a3e:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109a41:	8b 45 08             	mov    0x8(%ebp),%eax
80109a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a4a:	0f b6 00             	movzbl (%eax),%eax
80109a4d:	83 e0 0f             	and    $0xf,%eax
80109a50:	01 c0                	add    %eax,%eax
80109a52:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109a55:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109a5c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109a63:	eb 48                	jmp    80109aad <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109a65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a68:	01 c0                	add    %eax,%eax
80109a6a:	89 c2                	mov    %eax,%edx
80109a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a6f:	01 d0                	add    %edx,%eax
80109a71:	0f b6 00             	movzbl (%eax),%eax
80109a74:	0f b6 c0             	movzbl %al,%eax
80109a77:	c1 e0 08             	shl    $0x8,%eax
80109a7a:	89 c2                	mov    %eax,%edx
80109a7c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109a7f:	01 c0                	add    %eax,%eax
80109a81:	8d 48 01             	lea    0x1(%eax),%ecx
80109a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a87:	01 c8                	add    %ecx,%eax
80109a89:	0f b6 00             	movzbl (%eax),%eax
80109a8c:	0f b6 c0             	movzbl %al,%eax
80109a8f:	01 d0                	add    %edx,%eax
80109a91:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109a94:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109a9b:	76 0c                	jbe    80109aa9 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
80109a9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109aa0:	0f b7 c0             	movzwl %ax,%eax
80109aa3:	83 c0 01             	add    $0x1,%eax
80109aa6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109aa9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109aad:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109ab1:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109ab4:	7c af                	jl     80109a65 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109ab6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109ab9:	f7 d0                	not    %eax
}
80109abb:	c9                   	leave
80109abc:	c3                   	ret

80109abd <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
80109abd:	55                   	push   %ebp
80109abe:	89 e5                	mov    %esp,%ebp
80109ac0:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
80109ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80109ac6:	83 c0 0e             	add    $0xe,%eax
80109ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109acf:	0f b6 00             	movzbl (%eax),%eax
80109ad2:	0f b6 c0             	movzbl %al,%eax
80109ad5:	83 e0 0f             	and    $0xf,%eax
80109ad8:	c1 e0 02             	shl    $0x2,%eax
80109adb:	89 c2                	mov    %eax,%edx
80109add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ae0:	01 d0                	add    %edx,%eax
80109ae2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
80109ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ae8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80109aec:	84 c0                	test   %al,%al
80109aee:	75 4f                	jne    80109b3f <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
80109af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109af3:	0f b6 00             	movzbl (%eax),%eax
80109af6:	3c 08                	cmp    $0x8,%al
80109af8:	75 45                	jne    80109b3f <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
80109afa:	e8 8b 91 ff ff       	call   80102c8a <kalloc>
80109aff:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
80109b02:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
80109b09:	83 ec 04             	sub    $0x4,%esp
80109b0c:	8d 45 e8             	lea    -0x18(%ebp),%eax
80109b0f:	50                   	push   %eax
80109b10:	ff 75 ec             	push   -0x14(%ebp)
80109b13:	ff 75 08             	push   0x8(%ebp)
80109b16:	e8 78 00 00 00       	call   80109b93 <icmp_reply_pkt_create>
80109b1b:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109b1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b21:	83 ec 08             	sub    $0x8,%esp
80109b24:	50                   	push   %eax
80109b25:	ff 75 ec             	push   -0x14(%ebp)
80109b28:	e8 ad f4 ff ff       	call   80108fda <i8254_send>
80109b2d:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109b30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109b33:	83 ec 0c             	sub    $0xc,%esp
80109b36:	50                   	push   %eax
80109b37:	e8 b4 90 ff ff       	call   80102bf0 <kfree>
80109b3c:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109b3f:	90                   	nop
80109b40:	c9                   	leave
80109b41:	c3                   	ret

80109b42 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109b42:	55                   	push   %ebp
80109b43:	89 e5                	mov    %esp,%ebp
80109b45:	53                   	push   %ebx
80109b46:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109b49:	8b 45 08             	mov    0x8(%ebp),%eax
80109b4c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109b50:	0f b7 c0             	movzwl %ax,%eax
80109b53:	83 ec 0c             	sub    $0xc,%esp
80109b56:	50                   	push   %eax
80109b57:	e8 d3 fd ff ff       	call   8010992f <N2H_ushort>
80109b5c:	83 c4 10             	add    $0x10,%esp
80109b5f:	0f b7 d8             	movzwl %ax,%ebx
80109b62:	8b 45 08             	mov    0x8(%ebp),%eax
80109b65:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109b69:	0f b7 c0             	movzwl %ax,%eax
80109b6c:	83 ec 0c             	sub    $0xc,%esp
80109b6f:	50                   	push   %eax
80109b70:	e8 ba fd ff ff       	call   8010992f <N2H_ushort>
80109b75:	83 c4 10             	add    $0x10,%esp
80109b78:	0f b7 c0             	movzwl %ax,%eax
80109b7b:	83 ec 04             	sub    $0x4,%esp
80109b7e:	53                   	push   %ebx
80109b7f:	50                   	push   %eax
80109b80:	68 03 c4 10 80       	push   $0x8010c403
80109b85:	e8 6a 68 ff ff       	call   801003f4 <cprintf>
80109b8a:	83 c4 10             	add    $0x10,%esp
}
80109b8d:	90                   	nop
80109b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109b91:	c9                   	leave
80109b92:	c3                   	ret

80109b93 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109b93:	55                   	push   %ebp
80109b94:	89 e5                	mov    %esp,%ebp
80109b96:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109b99:	8b 45 08             	mov    0x8(%ebp),%eax
80109b9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80109ba2:	83 c0 0e             	add    $0xe,%eax
80109ba5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bab:	0f b6 00             	movzbl (%eax),%eax
80109bae:	0f b6 c0             	movzbl %al,%eax
80109bb1:	83 e0 0f             	and    $0xf,%eax
80109bb4:	c1 e0 02             	shl    $0x2,%eax
80109bb7:	89 c2                	mov    %eax,%edx
80109bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bbc:	01 d0                	add    %edx,%eax
80109bbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bc4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
80109bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bca:	83 c0 0e             	add    $0xe,%eax
80109bcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
80109bd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bd3:	83 c0 14             	add    $0x14,%eax
80109bd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
80109bd9:	8b 45 10             	mov    0x10(%ebp),%eax
80109bdc:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109be5:	8d 50 06             	lea    0x6(%eax),%edx
80109be8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109beb:	83 ec 04             	sub    $0x4,%esp
80109bee:	6a 06                	push   $0x6
80109bf0:	52                   	push   %edx
80109bf1:	50                   	push   %eax
80109bf2:	e8 45 b3 ff ff       	call   80104f3c <memmove>
80109bf7:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109bfa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bfd:	83 c0 06             	add    $0x6,%eax
80109c00:	83 ec 04             	sub    $0x4,%esp
80109c03:	6a 06                	push   $0x6
80109c05:	68 c0 9d 11 80       	push   $0x80119dc0
80109c0a:	50                   	push   %eax
80109c0b:	e8 2c b3 ff ff       	call   80104f3c <memmove>
80109c10:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c13:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c16:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c1d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c24:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c2a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109c2e:	83 ec 0c             	sub    $0xc,%esp
80109c31:	6a 54                	push   $0x54
80109c33:	e8 0e fd ff ff       	call   80109946 <H2N_ushort>
80109c38:	83 c4 10             	add    $0x10,%esp
80109c3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c3e:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c42:	0f b7 15 a0 a0 11 80 	movzwl 0x8011a0a0,%edx
80109c49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c4c:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c50:	0f b7 05 a0 a0 11 80 	movzwl 0x8011a0a0,%eax
80109c57:	83 c0 01             	add    $0x1,%eax
80109c5a:	66 a3 a0 a0 11 80    	mov    %ax,0x8011a0a0
  ipv4_send->fragment = H2N_ushort(0x4000);
80109c60:	83 ec 0c             	sub    $0xc,%esp
80109c63:	68 00 40 00 00       	push   $0x4000
80109c68:	e8 d9 fc ff ff       	call   80109946 <H2N_ushort>
80109c6d:	83 c4 10             	add    $0x10,%esp
80109c70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c73:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c7a:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c81:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c88:	83 c0 0c             	add    $0xc,%eax
80109c8b:	83 ec 04             	sub    $0x4,%esp
80109c8e:	6a 04                	push   $0x4
80109c90:	68 e4 f4 10 80       	push   $0x8010f4e4
80109c95:	50                   	push   %eax
80109c96:	e8 a1 b2 ff ff       	call   80104f3c <memmove>
80109c9b:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ca1:	8d 50 0c             	lea    0xc(%eax),%edx
80109ca4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ca7:	83 c0 10             	add    $0x10,%eax
80109caa:	83 ec 04             	sub    $0x4,%esp
80109cad:	6a 04                	push   $0x4
80109caf:	52                   	push   %edx
80109cb0:	50                   	push   %eax
80109cb1:	e8 86 b2 ff ff       	call   80104f3c <memmove>
80109cb6:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109cb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cbc:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109cc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cc5:	83 ec 0c             	sub    $0xc,%esp
80109cc8:	50                   	push   %eax
80109cc9:	e8 6d fd ff ff       	call   80109a3b <ipv4_chksum>
80109cce:	83 c4 10             	add    $0x10,%esp
80109cd1:	0f b7 c0             	movzwl %ax,%eax
80109cd4:	83 ec 0c             	sub    $0xc,%esp
80109cd7:	50                   	push   %eax
80109cd8:	e8 69 fc ff ff       	call   80109946 <H2N_ushort>
80109cdd:	83 c4 10             	add    $0x10,%esp
80109ce0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109ce3:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
80109ce7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cea:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
80109ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cf0:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
80109cf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109cf7:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80109cfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cfe:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
80109d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d05:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80109d09:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d0c:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
80109d10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d13:	8d 50 08             	lea    0x8(%eax),%edx
80109d16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d19:	83 c0 08             	add    $0x8,%eax
80109d1c:	83 ec 04             	sub    $0x4,%esp
80109d1f:	6a 08                	push   $0x8
80109d21:	52                   	push   %edx
80109d22:	50                   	push   %eax
80109d23:	e8 14 b2 ff ff       	call   80104f3c <memmove>
80109d28:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109d2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d2e:	8d 50 10             	lea    0x10(%eax),%edx
80109d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d34:	83 c0 10             	add    $0x10,%eax
80109d37:	83 ec 04             	sub    $0x4,%esp
80109d3a:	6a 30                	push   $0x30
80109d3c:	52                   	push   %edx
80109d3d:	50                   	push   %eax
80109d3e:	e8 f9 b1 ff ff       	call   80104f3c <memmove>
80109d43:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109d46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d49:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109d4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d52:	83 ec 0c             	sub    $0xc,%esp
80109d55:	50                   	push   %eax
80109d56:	e8 1c 00 00 00       	call   80109d77 <icmp_chksum>
80109d5b:	83 c4 10             	add    $0x10,%esp
80109d5e:	0f b7 c0             	movzwl %ax,%eax
80109d61:	83 ec 0c             	sub    $0xc,%esp
80109d64:	50                   	push   %eax
80109d65:	e8 dc fb ff ff       	call   80109946 <H2N_ushort>
80109d6a:	83 c4 10             	add    $0x10,%esp
80109d6d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d70:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109d74:	90                   	nop
80109d75:	c9                   	leave
80109d76:	c3                   	ret

80109d77 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109d77:	55                   	push   %ebp
80109d78:	89 e5                	mov    %esp,%ebp
80109d7a:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
80109d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80109d80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109d83:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109d8a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109d91:	eb 48                	jmp    80109ddb <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d93:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109d96:	01 c0                	add    %eax,%eax
80109d98:	89 c2                	mov    %eax,%edx
80109d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d9d:	01 d0                	add    %edx,%eax
80109d9f:	0f b6 00             	movzbl (%eax),%eax
80109da2:	0f b6 c0             	movzbl %al,%eax
80109da5:	c1 e0 08             	shl    $0x8,%eax
80109da8:	89 c2                	mov    %eax,%edx
80109daa:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109dad:	01 c0                	add    %eax,%eax
80109daf:	8d 48 01             	lea    0x1(%eax),%ecx
80109db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109db5:	01 c8                	add    %ecx,%eax
80109db7:	0f b6 00             	movzbl (%eax),%eax
80109dba:	0f b6 c0             	movzbl %al,%eax
80109dbd:	01 d0                	add    %edx,%eax
80109dbf:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109dc2:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109dc9:	76 0c                	jbe    80109dd7 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
80109dcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109dce:	0f b7 c0             	movzwl %ax,%eax
80109dd1:	83 c0 01             	add    $0x1,%eax
80109dd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109dd7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80109ddb:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
80109ddf:	7e b2                	jle    80109d93 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
80109de1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109de4:	f7 d0                	not    %eax
}
80109de6:	c9                   	leave
80109de7:	c3                   	ret

80109de8 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
80109de8:	55                   	push   %ebp
80109de9:	89 e5                	mov    %esp,%ebp
80109deb:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
80109dee:	8b 45 08             	mov    0x8(%ebp),%eax
80109df1:	83 c0 0e             	add    $0xe,%eax
80109df4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
80109df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dfa:	0f b6 00             	movzbl (%eax),%eax
80109dfd:	0f b6 c0             	movzbl %al,%eax
80109e00:	83 e0 0f             	and    $0xf,%eax
80109e03:	c1 e0 02             	shl    $0x2,%eax
80109e06:	89 c2                	mov    %eax,%edx
80109e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e0b:	01 d0                	add    %edx,%eax
80109e0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
80109e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e13:	83 c0 14             	add    $0x14,%eax
80109e16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
80109e19:	e8 6c 8e ff ff       	call   80102c8a <kalloc>
80109e1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109e21:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e2b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e2f:	0f b6 c0             	movzbl %al,%eax
80109e32:	83 e0 02             	and    $0x2,%eax
80109e35:	85 c0                	test   %eax,%eax
80109e37:	74 3d                	je     80109e76 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109e39:	83 ec 0c             	sub    $0xc,%esp
80109e3c:	6a 00                	push   $0x0
80109e3e:	6a 12                	push   $0x12
80109e40:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109e43:	50                   	push   %eax
80109e44:	ff 75 e8             	push   -0x18(%ebp)
80109e47:	ff 75 08             	push   0x8(%ebp)
80109e4a:	e8 a2 01 00 00       	call   80109ff1 <tcp_pkt_create>
80109e4f:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109e52:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109e55:	83 ec 08             	sub    $0x8,%esp
80109e58:	50                   	push   %eax
80109e59:	ff 75 e8             	push   -0x18(%ebp)
80109e5c:	e8 79 f1 ff ff       	call   80108fda <i8254_send>
80109e61:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109e64:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
80109e69:	83 c0 01             	add    $0x1,%eax
80109e6c:	a3 a4 a0 11 80       	mov    %eax,0x8011a0a4
80109e71:	e9 69 01 00 00       	jmp    80109fdf <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e79:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109e7d:	3c 18                	cmp    $0x18,%al
80109e7f:	0f 85 10 01 00 00    	jne    80109f95 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109e85:	83 ec 04             	sub    $0x4,%esp
80109e88:	6a 03                	push   $0x3
80109e8a:	68 1e c4 10 80       	push   $0x8010c41e
80109e8f:	ff 75 ec             	push   -0x14(%ebp)
80109e92:	e8 4d b0 ff ff       	call   80104ee4 <memcmp>
80109e97:	83 c4 10             	add    $0x10,%esp
80109e9a:	85 c0                	test   %eax,%eax
80109e9c:	74 74                	je     80109f12 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109e9e:	83 ec 0c             	sub    $0xc,%esp
80109ea1:	68 22 c4 10 80       	push   $0x8010c422
80109ea6:	e8 49 65 ff ff       	call   801003f4 <cprintf>
80109eab:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109eae:	83 ec 0c             	sub    $0xc,%esp
80109eb1:	6a 00                	push   $0x0
80109eb3:	6a 10                	push   $0x10
80109eb5:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109eb8:	50                   	push   %eax
80109eb9:	ff 75 e8             	push   -0x18(%ebp)
80109ebc:	ff 75 08             	push   0x8(%ebp)
80109ebf:	e8 2d 01 00 00       	call   80109ff1 <tcp_pkt_create>
80109ec4:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109ec7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109eca:	83 ec 08             	sub    $0x8,%esp
80109ecd:	50                   	push   %eax
80109ece:	ff 75 e8             	push   -0x18(%ebp)
80109ed1:	e8 04 f1 ff ff       	call   80108fda <i8254_send>
80109ed6:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ed9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109edc:	83 c0 36             	add    $0x36,%eax
80109edf:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ee2:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109ee5:	50                   	push   %eax
80109ee6:	ff 75 e0             	push   -0x20(%ebp)
80109ee9:	6a 00                	push   $0x0
80109eeb:	6a 00                	push   $0x0
80109eed:	e8 5a 04 00 00       	call   8010a34c <http_proc>
80109ef2:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ef5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ef8:	83 ec 0c             	sub    $0xc,%esp
80109efb:	50                   	push   %eax
80109efc:	6a 18                	push   $0x18
80109efe:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f01:	50                   	push   %eax
80109f02:	ff 75 e8             	push   -0x18(%ebp)
80109f05:	ff 75 08             	push   0x8(%ebp)
80109f08:	e8 e4 00 00 00       	call   80109ff1 <tcp_pkt_create>
80109f0d:	83 c4 20             	add    $0x20,%esp
80109f10:	eb 62                	jmp    80109f74 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109f12:	83 ec 0c             	sub    $0xc,%esp
80109f15:	6a 00                	push   $0x0
80109f17:	6a 10                	push   $0x10
80109f19:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f1c:	50                   	push   %eax
80109f1d:	ff 75 e8             	push   -0x18(%ebp)
80109f20:	ff 75 08             	push   0x8(%ebp)
80109f23:	e8 c9 00 00 00       	call   80109ff1 <tcp_pkt_create>
80109f28:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109f2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f2e:	83 ec 08             	sub    $0x8,%esp
80109f31:	50                   	push   %eax
80109f32:	ff 75 e8             	push   -0x18(%ebp)
80109f35:	e8 a0 f0 ff ff       	call   80108fda <i8254_send>
80109f3a:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109f3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109f40:	83 c0 36             	add    $0x36,%eax
80109f43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109f46:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109f49:	50                   	push   %eax
80109f4a:	ff 75 e4             	push   -0x1c(%ebp)
80109f4d:	6a 00                	push   $0x0
80109f4f:	6a 00                	push   $0x0
80109f51:	e8 f6 03 00 00       	call   8010a34c <http_proc>
80109f56:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109f59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109f5c:	83 ec 0c             	sub    $0xc,%esp
80109f5f:	50                   	push   %eax
80109f60:	6a 18                	push   $0x18
80109f62:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109f65:	50                   	push   %eax
80109f66:	ff 75 e8             	push   -0x18(%ebp)
80109f69:	ff 75 08             	push   0x8(%ebp)
80109f6c:	e8 80 00 00 00       	call   80109ff1 <tcp_pkt_create>
80109f71:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109f74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109f77:	83 ec 08             	sub    $0x8,%esp
80109f7a:	50                   	push   %eax
80109f7b:	ff 75 e8             	push   -0x18(%ebp)
80109f7e:	e8 57 f0 ff ff       	call   80108fda <i8254_send>
80109f83:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109f86:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
80109f8b:	83 c0 01             	add    $0x1,%eax
80109f8e:	a3 a4 a0 11 80       	mov    %eax,0x8011a0a4
80109f93:	eb 4a                	jmp    80109fdf <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f98:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109f9c:	3c 10                	cmp    $0x10,%al
80109f9e:	75 3f                	jne    80109fdf <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109fa0:	a1 a8 a0 11 80       	mov    0x8011a0a8,%eax
80109fa5:	83 f8 01             	cmp    $0x1,%eax
80109fa8:	75 35                	jne    80109fdf <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109faa:	83 ec 0c             	sub    $0xc,%esp
80109fad:	6a 00                	push   $0x0
80109faf:	6a 01                	push   $0x1
80109fb1:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109fb4:	50                   	push   %eax
80109fb5:	ff 75 e8             	push   -0x18(%ebp)
80109fb8:	ff 75 08             	push   0x8(%ebp)
80109fbb:	e8 31 00 00 00       	call   80109ff1 <tcp_pkt_create>
80109fc0:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109fc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109fc6:	83 ec 08             	sub    $0x8,%esp
80109fc9:	50                   	push   %eax
80109fca:	ff 75 e8             	push   -0x18(%ebp)
80109fcd:	e8 08 f0 ff ff       	call   80108fda <i8254_send>
80109fd2:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109fd5:	c7 05 a8 a0 11 80 00 	movl   $0x0,0x8011a0a8
80109fdc:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109fdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fe2:	83 ec 0c             	sub    $0xc,%esp
80109fe5:	50                   	push   %eax
80109fe6:	e8 05 8c ff ff       	call   80102bf0 <kfree>
80109feb:	83 c4 10             	add    $0x10,%esp
}
80109fee:	90                   	nop
80109fef:	c9                   	leave
80109ff0:	c3                   	ret

80109ff1 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109ff1:	55                   	push   %ebp
80109ff2:	89 e5                	mov    %esp,%ebp
80109ff4:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80109ffa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109ffd:	8b 45 08             	mov    0x8(%ebp),%eax
8010a000:	83 c0 0e             	add    $0xe,%eax
8010a003:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
8010a006:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a009:	0f b6 00             	movzbl (%eax),%eax
8010a00c:	0f b6 c0             	movzbl %al,%eax
8010a00f:	83 e0 0f             	and    $0xf,%eax
8010a012:	c1 e0 02             	shl    $0x2,%eax
8010a015:	89 c2                	mov    %eax,%edx
8010a017:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a01a:	01 d0                	add    %edx,%eax
8010a01c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010a01f:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a022:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
8010a025:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a028:	83 c0 0e             	add    $0xe,%eax
8010a02b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
8010a02e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a031:	83 c0 14             	add    $0x14,%eax
8010a034:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
8010a037:	8b 45 18             	mov    0x18(%ebp),%eax
8010a03a:	8d 50 36             	lea    0x36(%eax),%edx
8010a03d:	8b 45 10             	mov    0x10(%ebp),%eax
8010a040:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
8010a042:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a045:	8d 50 06             	lea    0x6(%eax),%edx
8010a048:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a04b:	83 ec 04             	sub    $0x4,%esp
8010a04e:	6a 06                	push   $0x6
8010a050:	52                   	push   %edx
8010a051:	50                   	push   %eax
8010a052:	e8 e5 ae ff ff       	call   80104f3c <memmove>
8010a057:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
8010a05a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a05d:	83 c0 06             	add    $0x6,%eax
8010a060:	83 ec 04             	sub    $0x4,%esp
8010a063:	6a 06                	push   $0x6
8010a065:	68 c0 9d 11 80       	push   $0x80119dc0
8010a06a:	50                   	push   %eax
8010a06b:	e8 cc ae ff ff       	call   80104f3c <memmove>
8010a070:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
8010a073:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a076:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
8010a07a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a07d:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
8010a081:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a084:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
8010a087:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a08a:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
8010a08e:	8b 45 18             	mov    0x18(%ebp),%eax
8010a091:	83 c0 28             	add    $0x28,%eax
8010a094:	0f b7 c0             	movzwl %ax,%eax
8010a097:	83 ec 0c             	sub    $0xc,%esp
8010a09a:	50                   	push   %eax
8010a09b:	e8 a6 f8 ff ff       	call   80109946 <H2N_ushort>
8010a0a0:	83 c4 10             	add    $0x10,%esp
8010a0a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0a6:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
8010a0aa:	0f b7 15 a0 a0 11 80 	movzwl 0x8011a0a0,%edx
8010a0b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0b4:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010a0b8:	0f b7 05 a0 a0 11 80 	movzwl 0x8011a0a0,%eax
8010a0bf:	83 c0 01             	add    $0x1,%eax
8010a0c2:	66 a3 a0 a0 11 80    	mov    %ax,0x8011a0a0
  ipv4_send->fragment = H2N_ushort(0x0000);
8010a0c8:	83 ec 0c             	sub    $0xc,%esp
8010a0cb:	6a 00                	push   $0x0
8010a0cd:	e8 74 f8 ff ff       	call   80109946 <H2N_ushort>
8010a0d2:	83 c4 10             	add    $0x10,%esp
8010a0d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a0d8:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
8010a0dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0df:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
8010a0e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0e6:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
8010a0ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a0ed:	83 c0 0c             	add    $0xc,%eax
8010a0f0:	83 ec 04             	sub    $0x4,%esp
8010a0f3:	6a 04                	push   $0x4
8010a0f5:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a0fa:	50                   	push   %eax
8010a0fb:	e8 3c ae ff ff       	call   80104f3c <memmove>
8010a100:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010a103:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a106:	8d 50 0c             	lea    0xc(%eax),%edx
8010a109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a10c:	83 c0 10             	add    $0x10,%eax
8010a10f:	83 ec 04             	sub    $0x4,%esp
8010a112:	6a 04                	push   $0x4
8010a114:	52                   	push   %edx
8010a115:	50                   	push   %eax
8010a116:	e8 21 ae ff ff       	call   80104f3c <memmove>
8010a11b:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010a11e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a121:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
8010a127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a12a:	83 ec 0c             	sub    $0xc,%esp
8010a12d:	50                   	push   %eax
8010a12e:	e8 08 f9 ff ff       	call   80109a3b <ipv4_chksum>
8010a133:	83 c4 10             	add    $0x10,%esp
8010a136:	0f b7 c0             	movzwl %ax,%eax
8010a139:	83 ec 0c             	sub    $0xc,%esp
8010a13c:	50                   	push   %eax
8010a13d:	e8 04 f8 ff ff       	call   80109946 <H2N_ushort>
8010a142:	83 c4 10             	add    $0x10,%esp
8010a145:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010a148:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
8010a14c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a14f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010a153:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a156:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
8010a159:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a15c:	0f b7 10             	movzwl (%eax),%edx
8010a15f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a162:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
8010a166:	a1 a4 a0 11 80       	mov    0x8011a0a4,%eax
8010a16b:	83 ec 0c             	sub    $0xc,%esp
8010a16e:	50                   	push   %eax
8010a16f:	e8 e9 f7 ff ff       	call   8010995d <H2N_uint>
8010a174:	83 c4 10             	add    $0x10,%esp
8010a177:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a17a:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
8010a17d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a180:	8b 40 04             	mov    0x4(%eax),%eax
8010a183:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
8010a189:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a18c:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
8010a18f:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a192:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
8010a196:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a199:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
8010a19d:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1a0:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
8010a1a4:	8b 45 14             	mov    0x14(%ebp),%eax
8010a1a7:	89 c2                	mov    %eax,%edx
8010a1a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1ac:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
8010a1af:	83 ec 0c             	sub    $0xc,%esp
8010a1b2:	68 90 38 00 00       	push   $0x3890
8010a1b7:	e8 8a f7 ff ff       	call   80109946 <H2N_ushort>
8010a1bc:	83 c4 10             	add    $0x10,%esp
8010a1bf:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1c2:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
8010a1c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1c9:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
8010a1cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a1d2:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
8010a1d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a1db:	83 ec 0c             	sub    $0xc,%esp
8010a1de:	50                   	push   %eax
8010a1df:	e8 1f 00 00 00       	call   8010a203 <tcp_chksum>
8010a1e4:	83 c4 10             	add    $0x10,%esp
8010a1e7:	83 c0 08             	add    $0x8,%eax
8010a1ea:	0f b7 c0             	movzwl %ax,%eax
8010a1ed:	83 ec 0c             	sub    $0xc,%esp
8010a1f0:	50                   	push   %eax
8010a1f1:	e8 50 f7 ff ff       	call   80109946 <H2N_ushort>
8010a1f6:	83 c4 10             	add    $0x10,%esp
8010a1f9:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010a1fc:	66 89 42 10          	mov    %ax,0x10(%edx)


}
8010a200:	90                   	nop
8010a201:	c9                   	leave
8010a202:	c3                   	ret

8010a203 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
8010a203:	55                   	push   %ebp
8010a204:	89 e5                	mov    %esp,%ebp
8010a206:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
8010a209:	8b 45 08             	mov    0x8(%ebp),%eax
8010a20c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
8010a20f:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a212:	83 c0 14             	add    $0x14,%eax
8010a215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
8010a218:	83 ec 04             	sub    $0x4,%esp
8010a21b:	6a 04                	push   $0x4
8010a21d:	68 e4 f4 10 80       	push   $0x8010f4e4
8010a222:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a225:	50                   	push   %eax
8010a226:	e8 11 ad ff ff       	call   80104f3c <memmove>
8010a22b:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
8010a22e:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a231:	83 c0 0c             	add    $0xc,%eax
8010a234:	83 ec 04             	sub    $0x4,%esp
8010a237:	6a 04                	push   $0x4
8010a239:	50                   	push   %eax
8010a23a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a23d:	83 c0 04             	add    $0x4,%eax
8010a240:	50                   	push   %eax
8010a241:	e8 f6 ac ff ff       	call   80104f3c <memmove>
8010a246:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
8010a249:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
8010a24d:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
8010a251:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a254:	0f b7 40 02          	movzwl 0x2(%eax),%eax
8010a258:	0f b7 c0             	movzwl %ax,%eax
8010a25b:	83 ec 0c             	sub    $0xc,%esp
8010a25e:	50                   	push   %eax
8010a25f:	e8 cb f6 ff ff       	call   8010992f <N2H_ushort>
8010a264:	83 c4 10             	add    $0x10,%esp
8010a267:	83 e8 14             	sub    $0x14,%eax
8010a26a:	0f b7 c0             	movzwl %ax,%eax
8010a26d:	83 ec 0c             	sub    $0xc,%esp
8010a270:	50                   	push   %eax
8010a271:	e8 d0 f6 ff ff       	call   80109946 <H2N_ushort>
8010a276:	83 c4 10             	add    $0x10,%esp
8010a279:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
8010a27d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
8010a284:	8d 45 d4             	lea    -0x2c(%ebp),%eax
8010a287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
8010a28a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010a291:	eb 33                	jmp    8010a2c6 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a293:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a296:	01 c0                	add    %eax,%eax
8010a298:	89 c2                	mov    %eax,%edx
8010a29a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a29d:	01 d0                	add    %edx,%eax
8010a29f:	0f b6 00             	movzbl (%eax),%eax
8010a2a2:	0f b6 c0             	movzbl %al,%eax
8010a2a5:	c1 e0 08             	shl    $0x8,%eax
8010a2a8:	89 c2                	mov    %eax,%edx
8010a2aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a2ad:	01 c0                	add    %eax,%eax
8010a2af:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2b5:	01 c8                	add    %ecx,%eax
8010a2b7:	0f b6 00             	movzbl (%eax),%eax
8010a2ba:	0f b6 c0             	movzbl %al,%eax
8010a2bd:	01 d0                	add    %edx,%eax
8010a2bf:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
8010a2c2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010a2c6:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
8010a2ca:	7e c7                	jle    8010a293 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
8010a2cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010a2cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a2d2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010a2d9:	eb 33                	jmp    8010a30e <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
8010a2db:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2de:	01 c0                	add    %eax,%eax
8010a2e0:	89 c2                	mov    %eax,%edx
8010a2e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2e5:	01 d0                	add    %edx,%eax
8010a2e7:	0f b6 00             	movzbl (%eax),%eax
8010a2ea:	0f b6 c0             	movzbl %al,%eax
8010a2ed:	c1 e0 08             	shl    $0x8,%eax
8010a2f0:	89 c2                	mov    %eax,%edx
8010a2f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a2f5:	01 c0                	add    %eax,%eax
8010a2f7:	8d 48 01             	lea    0x1(%eax),%ecx
8010a2fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010a2fd:	01 c8                	add    %ecx,%eax
8010a2ff:	0f b6 00             	movzbl (%eax),%eax
8010a302:	0f b6 c0             	movzbl %al,%eax
8010a305:	01 d0                	add    %edx,%eax
8010a307:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
8010a30a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010a30e:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
8010a312:	0f b7 c0             	movzwl %ax,%eax
8010a315:	83 ec 0c             	sub    $0xc,%esp
8010a318:	50                   	push   %eax
8010a319:	e8 11 f6 ff ff       	call   8010992f <N2H_ushort>
8010a31e:	83 c4 10             	add    $0x10,%esp
8010a321:	66 d1 e8             	shr    $1,%ax
8010a324:	0f b7 c0             	movzwl %ax,%eax
8010a327:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010a32a:	7c af                	jl     8010a2db <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
8010a32c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a32f:	c1 e8 10             	shr    $0x10,%eax
8010a332:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
8010a335:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a338:	f7 d0                	not    %eax
}
8010a33a:	c9                   	leave
8010a33b:	c3                   	ret

8010a33c <tcp_fin>:

void tcp_fin(){
8010a33c:	55                   	push   %ebp
8010a33d:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
8010a33f:	c7 05 a8 a0 11 80 01 	movl   $0x1,0x8011a0a8
8010a346:	00 00 00 
}
8010a349:	90                   	nop
8010a34a:	5d                   	pop    %ebp
8010a34b:	c3                   	ret

8010a34c <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
8010a34c:	55                   	push   %ebp
8010a34d:	89 e5                	mov    %esp,%ebp
8010a34f:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
8010a352:	8b 45 10             	mov    0x10(%ebp),%eax
8010a355:	83 ec 04             	sub    $0x4,%esp
8010a358:	6a 00                	push   $0x0
8010a35a:	68 2b c4 10 80       	push   $0x8010c42b
8010a35f:	50                   	push   %eax
8010a360:	e8 65 00 00 00       	call   8010a3ca <http_strcpy>
8010a365:	83 c4 10             	add    $0x10,%esp
8010a368:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
8010a36b:	8b 45 10             	mov    0x10(%ebp),%eax
8010a36e:	83 ec 04             	sub    $0x4,%esp
8010a371:	ff 75 f4             	push   -0xc(%ebp)
8010a374:	68 3e c4 10 80       	push   $0x8010c43e
8010a379:	50                   	push   %eax
8010a37a:	e8 4b 00 00 00       	call   8010a3ca <http_strcpy>
8010a37f:	83 c4 10             	add    $0x10,%esp
8010a382:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
8010a385:	8b 45 10             	mov    0x10(%ebp),%eax
8010a388:	83 ec 04             	sub    $0x4,%esp
8010a38b:	ff 75 f4             	push   -0xc(%ebp)
8010a38e:	68 59 c4 10 80       	push   $0x8010c459
8010a393:	50                   	push   %eax
8010a394:	e8 31 00 00 00       	call   8010a3ca <http_strcpy>
8010a399:	83 c4 10             	add    $0x10,%esp
8010a39c:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
8010a39f:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a3a2:	83 e0 01             	and    $0x1,%eax
8010a3a5:	85 c0                	test   %eax,%eax
8010a3a7:	74 11                	je     8010a3ba <http_proc+0x6e>
    char *payload = (char *)send;
8010a3a9:	8b 45 10             	mov    0x10(%ebp),%eax
8010a3ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
8010a3af:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a3b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a3b5:	01 d0                	add    %edx,%eax
8010a3b7:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
8010a3ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010a3bd:	8b 45 14             	mov    0x14(%ebp),%eax
8010a3c0:	89 10                	mov    %edx,(%eax)
  tcp_fin();
8010a3c2:	e8 75 ff ff ff       	call   8010a33c <tcp_fin>
}
8010a3c7:	90                   	nop
8010a3c8:	c9                   	leave
8010a3c9:	c3                   	ret

8010a3ca <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
8010a3ca:	55                   	push   %ebp
8010a3cb:	89 e5                	mov    %esp,%ebp
8010a3cd:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
8010a3d0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
8010a3d7:	eb 20                	jmp    8010a3f9 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
8010a3d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3df:	01 d0                	add    %edx,%eax
8010a3e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010a3e4:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3e7:	01 ca                	add    %ecx,%edx
8010a3e9:	89 d1                	mov    %edx,%ecx
8010a3eb:	8b 55 08             	mov    0x8(%ebp),%edx
8010a3ee:	01 ca                	add    %ecx,%edx
8010a3f0:	0f b6 00             	movzbl (%eax),%eax
8010a3f3:	88 02                	mov    %al,(%edx)
    i++;
8010a3f5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
8010a3f9:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010a3fc:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a3ff:	01 d0                	add    %edx,%eax
8010a401:	0f b6 00             	movzbl (%eax),%eax
8010a404:	84 c0                	test   %al,%al
8010a406:	75 d1                	jne    8010a3d9 <http_strcpy+0xf>
  }
  return i;
8010a408:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010a40b:	c9                   	leave
8010a40c:	c3                   	ret
