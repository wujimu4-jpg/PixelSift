import Foundation
import Darwin
@main struct FormatSelectionTests {
 static func check(_ value: @autoclosure () -> Bool, _ label: String) { if !value() { print("FAIL: \(label)"); exit(1) }; print("PASS: \(label)") }
 static func wait(_ lib: DownloadLibrary) { let end=Date().addingTimeInterval(60); while lib.activeID != nil && Date()<end { RunLoop.current.run(until: Date().addingTimeInterval(0.05)) }; check(lib.activeID == nil,"queue settles") }
 static func main() throws {
 let root=URL(fileURLWithPath:CommandLine.arguments[1]),tools=URL(fileURLWithPath:CommandLine.arguments[2]);
 func f(_ id:String,_ width:Int,_ height:Int,_ v:String,_ a:String)->[String:Any] { ["format_id":id,"width":width,"height":height,"vcodec":v,"acodec":a,"url":"http://127.0.0.1:18764/sample.mp4","ext":"mp4"] }
 let object:[String:Any] = ["formats":[f("4k",3840,2160,"vp9","none"),f("1080",1920,1080,"avc1.640028","none"),f("720",1280,720,"h264","aac"),["format_id":"audio","vcodec":"none","acodec":"mp4a.40.2","url":"http://127.0.0.1:18764/sample.mp4"]]]
 let opts=SourceFormats.options(object)
 check(!opts.contains{$0.container=="mp4" && $0.height==2160},"VP9 4K never advertised as compatible MP4")
 check(opts.contains{$0.container=="mkv" && $0.height==2160 && $0.selector=="4k+audio"},"4K source remains available as MKV")
 check(opts.contains{$0.container=="mp4" && $0.height==1080 && $0.selector=="1080+audio"},"split H264/AAC pairing")
 check(SourceFormats.options(["formats":[f("silent",1280,720,"h264","none")]]).isEmpty,"no silent video advertised")
 check(SourceFormats.options(["formats":[f("unknown",1280,720,"","")]]).isEmpty,"unknown codecs do not imply MP4 support")
 check(SourceFormats.options(["formats":[f("portrait",1920,1080,"h264","aac")]]).contains{$0.height==1080},"resolution supported")
 check(SourceFormats.options(["formats":[f("portrait",1080,1920,"h264","aac")]]).contains{$0.height==1080},"portrait uses short edge")
 let lib=DownloadLibrary(tools:tools,support:root)
 lib.updating=true
 lib.preview("https://example.com/a https://example.com/b https://example.com/a")
 check(lib.state.jobs.count==2,"batch deduplication")
 let a=lib.state.jobs[0].id,b=lib.state.jobs[1].id
 lib.setMetadata(a,object:object);lib.setMetadata(b,object:["formats":[f("720",1280,720,"h264","aac")]])
 check(lib.state.jobs.allSatisfy{$0.state=="ready" && $0.draft==true},"drafts never auto-download")
 lib.commitDrafts([a,b])
 check(lib.state.jobs[0].draft==false && lib.state.jobs[1].draft==true,"commit only supported combinations")
 lib.selectDraft(b,container:"mp4",height:720);lib.commitDrafts([b,b]);check(lib.state.jobs.count==2 && lib.state.jobs[1].draft==false,"manual choice and duplicate commit safe")
 // Actual engine + FFmpeg integration, using a local H264/AAC video.
 lib.state.jobs=[];lib.updating=false;lib.state.destination=root.appendingPathComponent("downloads").path
 for c in ["mp4","mkv"] {
 var j=VideoJob(url:"http://127.0.0.1:18764/sample.mp4",platform:"其他",quality:"720",mode:"video",destination:lib.state.destination);j.draft=true;j.outputContainer=c;j.exactHeight=720
 lib.state.jobs.append(j)
 let info:[String:Any] = ["id":"fixture","title":"Format fixture","extractor":"generic","extractor_key":"Generic","webpage_url":j.url,"formats":[f("combined",1280,720,"h264","aac")]]
 let file=root.appendingPathComponent("extractor-info-\(j.id).json");try JSONSerialization.data(withJSONObject:info).write(to:file)
 lib.setMetadata(j.id,object:info,infoFile:file.path);lib.commitDrafts([j.id]);wait(lib)
 let done=lib.state.jobs.last!;check(done.state=="done" && done.file.hasSuffix("."+c),"real engine produces selected \(c) container")
 }
 var probeJob=VideoJob(url:"http://127.0.0.1:18764/sample.mp4",platform:"其他",quality:"720",mode:"video",destination:lib.state.destination)
 probeJob.draft=true;probeJob.outputContainer="mp4";probeJob.exactHeight=720;lib.state.jobs.append(probeJob)
 lib.setMetadata(probeJob.id,object:["formats":[["format_id":"unknown","url":probeJob.url,"ext":"mp4"]]])
 let deadline=Date().addingTimeInterval(30)
 while lib.state.jobs.last?.state == "inspecting" && Date()<deadline { RunLoop.current.run(until:Date().addingTimeInterval(0.05)) }
 check(lib.state.jobs.last?.state == "ready" && lib.selectedOption(lib.state.jobs.last!) != nil,"unknown direct source is probed before enabling MP4")
 lib.save()
 let restored=DownloadLibrary(tools:tools,support:root)
 check(restored.state.jobs.last?.draft==true,"draft survives restart")
 print("All format tests passed")
 }
}
