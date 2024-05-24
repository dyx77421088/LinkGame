Async code entrance  
@func: function, this function is a async procedure that can use Await* APIs to await on tasks  
`TaskAPI.Async(func, ...)`  

post a Task in non-async code and use a callback to receive finish event  
@task: Task  
@onDoneCallback: Action\<Task\>, when Task finish running, this callback will be invoked  
`TaskAPI.Post(task, onDoneCallback)`  

Await on a function or Task  
Await* APIs can be used inside this function  
NOTE:  
 any error will propagate up(throw exception),  
 which means if a error occured in this function or task, stack will rewind immediately,  
 and further code will not be executed.  
`TaskAPI.Await(funcOrTask, ...)`  

Await on a function or Task but catch error and stop error propagation  
Await* APIs can be used inside this function  
NOTE:  
 this function will not propagate error(not throw exception)  
@return: like pcall  
 first return value is a boolean flag  
 if true, followed by the return value of the function or task  
 if false, followed by error message  
`TaskAPI.AwaitCatchError(funcOrTask, ...)`  

Await until next frame  
`TaskAPI.AwaitNextFrame()`  

Await until next late update  
`TaskAPI.AwaitLateUpdate()`  

Await until next fixed update  
`TaskAPI.AwaitFixedUpdate()`  

Await until this end of frame  
`TaskAPI.AwaitEndOfFrame()`  

Await until \<seconds\> pass  
@seconds: seconds  
@realtime: use realtime instead of UnityEngine.Time.time which can be affected by time scale  
`TaskAPI.AwaitSeconds(seconds, realtime)`  

Await until predicate function returns true  
@pred: Func\<bool\>, predicate function  
`TaskAPI.AwaitUntil(pred)`  

Await while predicate function returns true  
@pred: Func\<bool\>, predicate function  
`TaskAPI.AwaitWhile(pred)`  

Await on all Tasks, continue when all of them have finshed running  
NOTE:  
 this function will not propagate error from Tasks  
 if you want to know if there is any error in individual Tasks, you will have to check each one of them  
`TaskAPI.AwaitAll(...)`  

Await on any Tasks, continue when any of them has finshed running  
NOTE:  
 await for the first one out, but the other Tasks are still running, we just not waiting them but we won't interrupt them  
 this function will not propagate error from Tasks  
 if you want to know if there is any error in individual Tasks, you will have to check each one of them  
`TaskAPI.AwaitAny(...)`  

Run Tasks one after another, wait until all of them are finished  
NOTE:  
 this function will not propagate error from Tasks  
 and if one Task in the middle has error, it won't stop running and just jump to the next one.  
`TaskAPI.AwaitSequential(...)`  

创建一个ChangeModelTask， 此时Task并未开始执行，其效果相当于调用ChangeModelTask.new  
更换角色模型, 参数是Model.ChangeModelByModelId的子集，只取了需要用到的一部分  
@model: Model  
@heroId: 需要更换的id  
@forceLODLevel: \[optional\], 强制使用第几个级别的LOD模型  
`TaskAPI.ChangeModelTask(model, heroId, forceLODLevel)`  

创建一个ChangeModelTask并等待其执行结束，参数与ChangeModelTask的构造函数一致  
更换角色模型, 参数是Model.ChangeModelByModelId的子集，只取了需要用到的一部分  
@model: Model  
@heroId: 需要更换的id  
@forceLODLevel: \[optional\], 强制使用第几个级别的LOD模型  
`TaskAPI.AwaitChangeModel(model, heroId, forceLODLevel)`  

创建一个LoadAssetTask， 此时Task并未开始执行，其效果相当于调用LoadAssetTask.new  
加载Asset, 参数与ResMgr.LoadAsync一致  
@prefabPath: prefab路径  
@type: asset类型  
@noClear: 是否在过场景的时候不自动卸载，true为不卸载  
`TaskAPI.LoadAssetTask(prefabPath, type, noClear)`  

创建一个LoadAssetTask并等待其执行结束，参数与LoadAssetTask的构造函数一致  
加载Asset, 参数与ResMgr.LoadAsync一致  
@prefabPath: prefab路径  
@type: asset类型  
@noClear: 是否在过场景的时候不自动卸载，true为不卸载  
`TaskAPI.AwaitLoadAsset(prefabPath, type, noClear)`  

创建一个InstantiateAssetTask， 此时Task并未开始执行，其效果相当于调用InstantiateAssetTask.new  
加载并Instantiate一个Asset  
@prefabPath: prefab路径  
@instantiateArgs: table, unpack并传递给GameObject.Instantiate的参数  
@type: asset类型  
@noClear: 是否在过场景的时候不自动卸载，true为不卸载  
`TaskAPI.InstantiateAssetTask(prefabPath, instantiateArgs, type, noClear)`  

创建一个InstantiateAssetTask并等待其执行结束，参数与InstantiateAssetTask的构造函数一致  
加载并Instantiate一个Asset  
@prefabPath: prefab路径  
@instantiateArgs: table, unpack并传递给GameObject.Instantiate的参数  
@type: asset类型  
@noClear: 是否在过场景的时候不自动卸载，true为不卸载  
`TaskAPI.AwaitInstantiateAsset(prefabPath, instantiateArgs, type, noClear)`  

